# frozen_string_literal: true

module CommonControllerActions
  extend ActiveSupport::Concern

  include SiteNavigation

  included do
    protect_from_forgery
    layout :layout_by_resource
    helper :all
    helper Koi::NavigationHelper
    before_action :sign_in_as_admin!, if: -> { Rails.env.development? && !admin_signed_in? }
  end

  protected

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
    resource_or_scope.is_a?(AdminUser) ? koi_engine.root_path : super
  end

  # FIXME: Hack to redirect back to admin after admin logout
  def after_sign_out_path_for(resource_or_scope)
    resource_or_scope == :admin ? koi_engine.root_path : super
  end

  def sign_in_as_admin!
    if (admin = AdminUser.find_by(role: "Super")).present?
      sign_in :admin, admin
    end
  end
end
