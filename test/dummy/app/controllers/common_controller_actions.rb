module CommonControllerActions

  extend ActiveSupport::Concern

  included do
    protect_from_forgery
    layout :layout_by_resource
    helper :all
    before_filter :check_authorization_for_profiling
  end

  protected

  def check_authorization_for_profiling
    if admin_signed_in? && current_admin.god?
      Rack::MiniProfiler.authorize_request
    end
  end

  # FIXME: Hack to set layout for admin devise resources
  def layout_by_resource
    if devise_controller? && resource_name == :admin
      "koi/devise"
    else
      "application"
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

end
