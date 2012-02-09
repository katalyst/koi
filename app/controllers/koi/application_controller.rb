module Koi
  class ApplicationController < ActionController::Base
    def index
      render text: "Koi Admin"
    end
  end
end
