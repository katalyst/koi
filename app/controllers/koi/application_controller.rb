module Koi
  class ApplicationController < ActionController::Base
    helper :all
    layout 'koi/admin_crud'

    before_filter :authenticate_admin!, :except => :login

    def after_sign_out_path_for(resource_or_scope)
      debugger
      resource_or_scope == :admin ? admin_root_path : super
    end

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to koi_engine.new_admin_session_path
      end
    end
  end
end
