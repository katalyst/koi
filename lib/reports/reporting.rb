module Reports
  class Reporting
  	def self.generate_report(reports, collection)
      return reports.map { |report| Reporting.new(report, collection).process }
    end

    attr_accessor :collection, :span, :field, :strategy

    def initialize(report, collection)
      @span       = report[:span] ||= :created_at
      @field      = report[:field]
      @strategy   = report[:strategy] ||= :count
      @collection = collection.sort_by(&@span)
    end

    def process
      dates = Hash.new { |h,v| h[v] = 0 }
      @collection.each do |c|
        if @strategy == :count
          dates[c.send(@span).to_date.to_datetime.to_i] += c.send(@field)
        else
          dates[c.send(@span).to_date.to_datetime.to_i] += 1
        end
      end

      (@collection.first.send(@span).to_date..@collection.last.send(@span).to_date).each do |d|
        dates[d.to_datetime.to_i]
      end

      dates.sort.map { |k,v| { x: k, y: v} }
    end
  end
end
