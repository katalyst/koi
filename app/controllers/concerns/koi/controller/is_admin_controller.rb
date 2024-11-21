# frozen_string_literal: true

module Koi
  module Controller
    module IsAdminController
      extend ActiveSupport::Concern

      class_methods do
        def authenticate_local_admins(value)
          Koi::Controller::IsAdminController.authenticate_local_admins = value
        end
      end

      included do
        include HasAdminUsers
        include HasAttachments
        include Katalyst::Tables::Backend
        include ::Pagy::Backend

        default_form_builder "Koi::FormBuilder"
        default_table_component Koi::TableComponent
        default_table_query_component Koi::TableQueryComponent
        default_summary_table_component Koi::SummaryTableComponent

        helper Katalyst::GOVUK::Formbuilder::Frontend
        helper Katalyst::Navigation::FrontendHelper
        helper Katalyst::Tables::Frontend
        helper ::Pagy::Frontend
        helper Koi::Pagy::Frontend
        helper IndexActionsHelper
        helper :all

        layout -> { turbo_frame_layout || "koi/application" }
      end

      class << self
        attr_accessor :authenticate_local_admins
      end

      protected

      def authenticate_local_admin
        return if admin_signed_in? || !Rails.env.development?

        session[:admin_user_id] =
          Admin::User.where(email: %W[#{ENV.fetch('USER', nil)}@katalyst.com.au admin@katalyst.com.au]).first&.id

        flash.delete(:redirect) if (redirect = flash[:redirect])

        redirect_to(redirect || admin_dashboard_path, status: :see_other)
      end

      def authenticate_local_admins?
        IsAdminController.authenticate_local_admins
      end

      def turbo_frame_layout
        if kpop_frame_request?
          "koi/frame"
        elsif turbo_frame_request?
          "turbo_rails/frame"
        end
      end
    end
  end
end
