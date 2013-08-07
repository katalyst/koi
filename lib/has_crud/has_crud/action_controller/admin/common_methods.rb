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

          def singular_name(to_sym=false)
            name = resource_class.to_s.underscore
            to_sym ? name : name.to_sym
          end

          def plural_name(to_sym=false)
            name = singular_name(:symbol).pluralize
            to_sym ? name : name.to_sym
          end

          def humanized(value=nil)
            value.to_s.gsub("_", " ").capitalize
          end

          def humanized_singular_name
            humanized singular_name
          end

          def humanized_plural_name
            humanized plural_name
          end

        end

      end
    end
  end
end
