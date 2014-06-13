module Reports

  class Charting

    attr_accessor :collection, :span, :field, :strategy, :colour, :name, :renderer, :scope

    def initialize(report, klass)
      @span       = report[:span]
      @field      = report[:field]
      @strategy   = report[:strategy]
      @colour     = report[:colour]
      @name       = report[:name]
      @renderer   = report[:renderer]
      scope       = report[:scope] || :scoped
      @collection = klass.send(scope).sort_by(&span)
    end

    def process
      dates = Hash.new { |h,v| h[v] = 0 }

      @collection.each do |c|
        if strategy == :sum
          dates[c.send(span).to_date.to_datetime.to_i] += c.send(@field)
        else
          dates[c.send(span).to_date.to_datetime.to_i] += 1
        end
      end

      ((@collection.first.send(span).to_date-1.day)..(@collection.last.send(span).to_date+1.day)).each do |d|
        dates[d.to_datetime.to_i]
      end

      {
        name:     name,
        values:   dates.sort.map { |k,v| { x: k, y: v} },
        colour:   colour,
        renderer: renderer,
        class:    'charting'
      }
    rescue
      {
        name:     name,
        values:   nil,
        colour:   colour,
        renderer: renderer,
        class:    'charting'
      }
    end

    def name
      @name || "#{@field} #{@strategy}"
    end

    def colour
      @colour || 'green'
    end

    def renderer
      @renderer || 'line'
    end

    def span
      @span || :created_at
    end

    def strategy
      @strategy || :count
    end

  end
end
