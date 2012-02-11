module Koi
  class ApplicationController < ActionController::Base
    before_filter :authenticate_admin!, :except => :login

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to new_admin_session_path
      end
    end
  end
end
