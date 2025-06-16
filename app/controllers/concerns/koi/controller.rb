# frozen_string_literal: true

module Koi
  module Controller
    extend ActiveSupport::Concern

    included do
      include HasAdminUsers
      include HasAttachments
      include Katalyst::Tables::Backend
      include ::Pagy::Backend

      default_form_builder "Koi::FormBuilder"
      default_table_component "Koi::TableComponent"
      default_table_query_component "Koi::TableQueryComponent"
      default_summary_table_component "Koi::SummaryTableComponent"

      # Dependency helpers
      helper Katalyst::GOVUK::Formbuilder::Frontend
      helper Katalyst::Navigation::FrontendHelper
      helper Katalyst::Tables::Frontend
      helper ::Pagy::Frontend

      # Koi Helpers
      helper FormHelper
      helper HeaderHelper
      helper Pagy::Frontend

      # @deprecated to be removed in Koi 5
      helper IndexActionsHelper

      layout -> { turbo_frame_request? ? "koi/frame" : "koi/application" }

      protect_from_forgery with: :exception
    end
  end
end
