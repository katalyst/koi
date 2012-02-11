module Koi
  class ApplicationController < ActionController::Base
    # before_filter :authenticate_admin!, only: [:login]

    def index
      render text: "Koi Admin"
    end

    def login
      render text: "Login Screen"
    end
  end
end
