module Koi
  class ApplicationController < ActionController::Base
    before_filter :authenticate_admin!

    def index
    end

    def login
      render text: "Login Screen"
    end
  end
end
