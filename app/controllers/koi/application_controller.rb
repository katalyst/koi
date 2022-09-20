# frozen_string_literal: true

module Koi
  class ApplicationController < ActionController::Base
    include HasCrud::ActionController
    include ExportableController
    include IsAdminController

    helper Katalyst::GOVUK::FormBuilder::Frontend
  end
end
