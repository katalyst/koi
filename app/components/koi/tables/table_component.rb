# frozen_string_literal: true

module Koi
  module Tables
    # Custom table component, in order to override the default header and body row components
    # which enables us to use our own custom header and body cell components
    class TableComponent < Katalyst::TableComponent
    end
  end
end
