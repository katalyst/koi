# frozen_string_literal: true

module Koi
  class PasswordsController < Devise::PasswordsController
    protected

    helper :all

    def after_sending_reset_password_instructions_path_for(_resource_name)
      koi_engine.root_path
    end
  end
end
