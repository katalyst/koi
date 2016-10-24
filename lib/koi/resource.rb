module Koi
  class Resource
    class << self
      def register(resource, &block)
        # Create controller class
        setup_controller(resource)
        # Eval register block
        class_eval(&block)
        # Setup routes
        Koi.router.register_resource(resource, @resource_actions)
      end

      def actions(*actions)
        @resource_actions = actions
      end

      def index(options={}, &block)
        @controller.const_set('IndexOptions', options)
        @controller.const_set('Index', block)
      end

      def form(&block)
        @form = block
        @controller.const_set('Form', @form)
      end

      def permit_params(*attributes)
        @controller.const_set('PermittedParams', attributes)
      end

      private

      #
      # Sets up a admin controller instance from resource
      #
      # @param [ActiveRecord::Base] resource
      #
      def setup_controller(resource)
        @controller = Admin.const_set("#{resource.name.pluralize}Controller",
                                      Class.new(Koi::AdminResourceController))
        @controller.send(:inherit_resources)
        @controller.send(:include, Koi::ResourceActions)
      end
    end
  end
end
