# frozen_string_literal: true

require "rails/generators/rails/scaffold/scaffold_generator"

module Koi
  class AdminGenerator < Rails::Generators::ScaffoldGenerator
    # Replace the default model generator with our own
    remove_hook_for(:orm)
    hook_for(:orm, in: :koi, as: :admin, default: true)

    # Disable default controller generation as we do not want to generate public
    # controllers by default
    remove_hook_for(:scaffold_controller)
    remove_hook_for(:resource_route)

    hook_for :admin_controller, in: :koi, as: :admin, type: :boolean, default: true do |instance, controller|
      args, opts, config = @_initializer
      opts               ||= {}

      # setting model_name so that generators will use the controller_class_path
      instance.invoke controller, args, { model_name: instance.name, **opts }, config
    end

    Rails::Generators::ModelGenerator.hook_for :admin_search, type: :boolean, default: true
    Rails::Generators::ModelGenerator.hook_for :ordinal_scope, type: :boolean, default: true
  end
end
