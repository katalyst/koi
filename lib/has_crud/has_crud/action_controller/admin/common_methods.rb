# frozen_string_literal: true

module HasCrud
  module ActionController
    module Admin
      module CommonMethods
        def self.included(base)
          base.send :include, InstanceMethods
        end

        module ClassMethods
        end

        module InstanceMethods
          def singular_name(to_sym = false)
            name = resource_class.model_name.element
            to_sym ? name : name.to_sym
          end

          def plural_name(to_sym = false)
            name = resource_class.model_name.collection
            to_sym ? name : name.to_sym
          end

          def humanized_singular_name
            resource_class.model_name.human
          end

          def humanized_plural_name
            resource_class.model_name.human.pluralize
          end
        end
      end
    end
  end
end
