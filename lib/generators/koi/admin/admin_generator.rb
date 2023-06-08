# frozen_string_literal: true

require "rails/generators/rails/scaffold/scaffold_generator"

module Koi
  class AdminGenerator < Rails::Generators::ScaffoldGenerator
    # Disable default controller generation as we do not want to generate public
    # controllers by default
    remove_hook_for(:scaffold_controller)
    remove_hook_for(:resource_route)

    hook_for :admin_controller, in: :koi, as: :admin, type: :boolean, default: true
  end
end
