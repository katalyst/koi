require 'reports/charting'
require 'reports/overview'

module Reports

  class Reporting
    def self.generate_report(overviews, charts, collection)
      reports = overviews.map { |report| Overview.new(report, collection).process }
      reports = reports | charts.map { |report| Charting.new(report, collection).process }
      reports
    end
  end

end
