module Koi
  class AdminCrudController < Koi::ApplicationController
    helper :all
    has_crud :admin => true
    defaults :route_prefix => 'admin'

    before_action :generate_reports, only: :index, if: :is_reportable?

    def index
      respond_to do |format|
        format.html
        format.js
        format.csv { respond_with_csv }
      end
    end

  protected

    # Matches missing route methods of the form (action_)?koi_(controller)_path,
    # and sends them to koi_engine instead.
    #
    # This is necessary because inherited_resources is resolving paths differently
    # depending on whether they belong to the koi_engine or not.
    #
    def method_missing key, *sig, &blk
      if match = /(\w+_|\b)koi_(\w+)_path$/.match(key)
        prefix, suffix = match.to_a.drop 1
        koi_engine.send :"#{ prefix }#{ suffix }_path", *sig, &blk
      else
        super
      end
    end

    def generate_reports
      overviews = collection.crud.settings[:admin][:overviews]
      charts    = collection.crud.settings[:admin][:charts]

      @report_data = Reports::Reporting.generate_report(overviews, charts, resource_class)
    end

  end
end
