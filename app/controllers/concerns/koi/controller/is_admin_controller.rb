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
        include Pagy::Backend

        default_form_builder "Koi::FormBuilder"

        helper Katalyst::GOVUK::Formbuilder::Frontend
        helper Katalyst::Navigation::FrontendHelper
        helper Katalyst::Tables::Frontend
        helper Pagy::Frontend
        helper IndexActionsHelper
        helper :all

        layout -> { turbo_frame_layout || "koi/application" }

        before_action :authenticate_local_admin, if: -> { Koi::Controller::IsAdminController.authenticate_local_admins }
        before_action :authenticate_admin, unless: :admin_signed_in?
      end

      class << self
        attr_accessor :authenticate_local_admins
      end

      protected

      def authenticate_local_admin
        return if admin_signed_in? || !Rails.env.development?

        session[:admin_user_id] =
          Admin::User.where(email: %W[#{ENV['USER']}@katalyst.com.au admin@katalyst.com.au]).first&.id
      end

      def authenticate_admin
        redirect_to new_admin_session_path, status: :temporary_redirect
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
