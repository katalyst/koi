class Admin
  def god?
    true
  end
end

module Koi
  class ApplicationController < ActionController::Base
    helper :all

    # before_filter :authenticate_admin!, :except => :login

    def after_sign_out_path_for(resource_or_scope)
      resource_or_scope == :admin ? admin_root_path : super
    end

    def current_admin
      new Admin
    end

    def login
      # if admin_signed_in?
        redirect_to dashboard_path
      # else
        # redirect_to new_admin_session_path
      # end
    end
  end
end
