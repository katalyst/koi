require_relative 'action_controller/crud_additions'
require_relative 'action_controller/crud_admin_additions'

module HasCrud
  module ActionController
    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
      base.send :helper_method, :has_crud?
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
    end
  end
end
