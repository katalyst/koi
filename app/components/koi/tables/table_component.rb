# frozen_string_literal: true

module Koi
  module Tables
    # Custom table component, in order to override the default header and body row components
    # which enables us to use our own custom header and body cell components
    class TableComponent < Katalyst::TableComponent
      def default_html_attributes
        { class: "index-table" }
      end
    end
  end
end
