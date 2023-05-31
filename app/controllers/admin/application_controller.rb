# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    include Koi::Controller::IsAdminController

    protect_from_forgery with: :exception
  end
end
