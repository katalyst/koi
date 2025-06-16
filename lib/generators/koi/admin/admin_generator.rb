# frozen_string_literal: true

require "rails/generators/named_base"

module Koi
  class AdminGenerator < Rails::Generators::NamedBase

    class_option :force, type: :boolean, default: true

    hook_for :admin_controller, in: :koi, as: :admin, type: :boolean, default: true do |instance, controller|
      args, opts, config = @_initializer
      opts               ||= {}

      # setting model_name so that generators will use the controller_class_path
      instance.invoke controller, args, { model_name: instance.name, **opts }, config
    end
  end
end
