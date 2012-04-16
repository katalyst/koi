require 'garb'

module Koi
  class ApplicationController < ActionController::Base
    helper :all
    # layout 'koi/admin_crud'
    before_filter :authenticate_admin!, :except => :login
    before_filter :load_google_analytics_session

    def login
      if admin_signed_in?
        redirect_to dashboard_path
      else
        redirect_to koi_engine.new_admin_session_path
      end
    end

    def load_google_analytics_session
      begin
        @result = Exits.analytics(params[:analytics])
      rescue Garb::AuthenticationRequest::AuthError
        @result = false
      end
    end
  end
end
