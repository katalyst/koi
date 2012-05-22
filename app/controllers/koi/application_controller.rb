require 'garb'

module Koi
  class ApplicationController < ActionController::Base
    helper :all
    # layout 'koi/admin_crud'
    before_filter :authenticate_admin, except: :login

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to koi_engine.new_admin_session_path
      end
    end

    def authenticate_admin
      redirect_to koi_engine.new_admin_session_path unless admin_signed_in?
    end
  end
end
