# frozen_string_literal: true

module Koi
  module Controller
    extend ActiveSupport::Concern

    included do
      include HasAdminUsers
      include HasAttachments
      include Katalyst::Tables::Backend

      if (pagy = "Pagy::Method".safe_constantize)
        include pagy
      elsif (pagy = "Pagy::Backend".safe_constantize)
        # @deprecated Pagy <43
        include pagy

        helper "::Pagy::Frontend".safe_constantize
      end

      default_form_builder "Koi::FormBuilder"
      default_table_component "Koi::TableComponent"
      default_table_query_component "Koi::TableQueryComponent"
      default_table_pagination_component "Koi::PagyNavComponent"
      default_summary_table_component "Koi::SummaryTableComponent"

      # Dependency helpers
      helper Katalyst::GOVUK::Formbuilder::Frontend
      helper Katalyst::Navigation::FrontendHelper
      helper Katalyst::Tables::Frontend

      # Koi Helpers
      helper FormHelper
      helper HeaderHelper
      helper ModalHelper
      helper Pagy::Frontend

      layout -> { turbo_frame_request? ? "koi/frame" : "koi/application" }

      protect_from_forgery with: :exception
    end
  end
end
