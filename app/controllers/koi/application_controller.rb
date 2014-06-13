require 'garb'

module Koi
  class ApplicationController < ActionController::Base
    helper :all
    layout :layout_by_resource
    before_filter :authenticate_admin, except: :login

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to koi_engine.new_admin_session_path
      end
    end

    def clear_cache
      Rails.logger.warn("[CACHE CLEAR] - Clearning entire cache manually by #{current_admin} request")
      Rails.cache.clear
      redirect_to :back
    end

    def index
      models = has_crud_models
        .select { |h| h.crud.settings[:admin][:reportable] }
        .select { |h| h.crud.settings[:admin][:overviews] }

      @report_data = []

      models.each do |model|
        overviews = model.crud.settings[:admin][:overviews]
        @report_data = @report_data | Reports::Reporting.generate_report(overviews, [], model)
      end
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
      resource_or_scope.is_a?(Admin) ? koi_engine.root_path : super
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
