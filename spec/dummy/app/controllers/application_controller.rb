class ApplicationController < ActionController::Base
  include CommonControllerActions

  protect_from_forgery with: :exception
end
