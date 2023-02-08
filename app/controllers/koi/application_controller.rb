# frozen_string_literal: true

module Koi
  class ApplicationController < ActionController::Base
    include IsAdminController
  end
end
