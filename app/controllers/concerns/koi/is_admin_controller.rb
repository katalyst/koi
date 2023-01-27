# frozen_string_literal: true

module Koi
  module IsAdminController
    extend ActiveSupport::Concern

    class_methods do
      def authenticate_local_admins(value)
        Koi::IsAdminController.authenticate_local_admins = value
      end
    end

    included do
      include HasAdminUsers
      include Katalyst::Tables::Backend
      include Pagy::Backend

      default_form_builder "Koi::FormBuilder"

      helper Katalyst::GOVUK::Formbuilder::Frontend
      helper Katalyst::Navigation::FrontendHelper
      helper Katalyst::Tables::Frontend
      helper Pagy::Frontend
      helper IndexActionsHelper
      helper :all

      layout "koi/application"

      before_action :authenticate_local_admin, if: -> { Koi::IsAdminController.authenticate_local_admins }
      before_action :authenticate_admin, unless: :admin_signed_in?
    end

    def clear_cache
      Rails.logger.warn("[CACHE CLEAR] - Cleaning entire cache manually by #{current_admin} request")
      Rails.cache.clear
      redirect_back(fallback_location: dashboard_path)
    end

    class << self
      attr_accessor :authenticate_local_admins
    end

    protected

    def authenticate_local_admin
      return if admin_signed_in? || !Rails.env.development?

      session[:admin_user_id] =
        AdminUser.where(email: %W[#{ENV['user']}@katalyst.com.au admin@katalyst.com.au]).first&.id
    end

    def authenticate_admin
      redirect_to koi_engine.new_admin_session_path, status: :temporary_redirect
    end
  end
end
