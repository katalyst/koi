# frozen_string_literal: true

module Koi
  class ApplicationController < ActionController::Base
    include HasCrud::ActionController
    include ExportableController
    include IsAdminController
    include Katalyst::Tables::Backend
    include Pagy::Backend

    default_form_builder "Koi::FormBuilder"

    helper Katalyst::GOVUK::Formbuilder::Frontend
    helper Katalyst::Tables::Frontend
    helper Pagy::Frontend
  end
end
