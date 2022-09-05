# frozen_string_literal: true

module Koi
  module IsAdminController
    extend ActiveSupport::Concern

    included do
      helper :all
      helper Katalyst::Navigation::FrontendHelper

      layout :layout_by_resource
      before_action :authenticate_admin, except: :login
    end

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to koi_engine.new_admin_session_path
      end
    end

    def clear_cache
      Rails.logger.warn("[CACHE CLEAR] - Cleaning entire cache manually by #{current_admin} request")
      Rails.cache.clear
      redirect_back(fallback_location: dashboard_path)
    end

    protected

    # FIXME: Hack to set layout for admin devise resources
    def layout_by_resource
      if devise_controller? && resource_name == :admin
        "koi/devise"
      else
        "koi/application"
      end
    end

    # FIXME: Hack to redirect back to admin after admin login
    def after_sign_in_path_for(resource_or_scope)
      resource_or_scope.is_a?(AdminUser) ? koi_engine.root_path : super
    end

    # FIXME: Hack to redirect back to admin after admin logout
    def after_sign_out_path_for(resource_or_scope)
      resource_or_scope == :admin ? koi_engine.root_path : super
    end

    def authenticate_admin
      redirect_to koi_engine.new_admin_session_path unless admin_signed_in?
    end
  end
end
