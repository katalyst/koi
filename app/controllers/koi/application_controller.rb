# frozen_string_literal: true

module Koi
  class ApplicationController < ActionController::Base
    include HasCrud::ActionController
    include ExportableController
    include IsAdminController
  end
end
