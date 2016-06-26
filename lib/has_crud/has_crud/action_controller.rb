require_relative 'action_controller/crud_additions'
require_relative 'action_controller/crud_admin_additions'

module HasCrud
  module ActionController
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
      base.send :helper_method, :has_crud?, :has_navigation_models, :has_crud_models
    end

    module ClassMethods
      def has_crud(options={})
        options ||= {}
        send :include, HasCrud::ActionController::CrudAdditions
        send :include, HasCrud::ActionController::CrudAdminAdditions if options[:admin]
      end

    end

    module InstanceMethods
      def has_crud?
        false
      end

      def has_navigation_models
        # get all models with has_crud navigation: true
        @has_navigation_models || has_crud_models.select{ |model| model.options[:navigation] }
      end

      def has_crud_models
        # Make sure all the models are loaded.
        Dir["#{Rails.root}/app/models/**/*.rb"].each { |path| require_dependency path }
        # Get all the models that have crud.
        Module.constants.collect { |c| eval(c.to_s) }.select do |constant|
          !constant.nil? && constant.is_a?(Class) && constant.respond_to?(:has_crud?) && constant.has_crud?
        end.sort_by { |type| type.to_s }
      end
    end
  end
end
