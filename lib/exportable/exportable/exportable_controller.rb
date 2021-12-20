# frozen_string_literal: true

module ExportableController
  extend ActiveSupport::Concern

  included do
    #
    # can be overriden in the crud controller to specify the
    # csv filename — e.g. based on the title of a parent resource
    #
    def csv_filename
      "#{resource_class.name.underscore.pluralize}-#{DateTime.current.strftime('%d_%m_%Y')}.csv"
    end

    def respond_with_csv
      unpaginated_collection = collection.limit(nil).offset(nil)
      send_data unpaginated_collection.to_formatted_csv, filename: csv_filename
    end
  end
end
