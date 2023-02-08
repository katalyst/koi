# frozen_string_literal: true

module Koi
  class SessionsController < Devise::SessionsController
    default_form_builder "Koi::FormBuilder"

    helper Katalyst::GOVUK::Formbuilder::Frontend
  end
end
