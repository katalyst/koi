# frozen_string_literal: true

module HasCrud
  module ActionController
    module Admin
      module CollectionMethods
        def self.included(base)
          base.send :include, InstanceMethods
        end

        module ClassMethods
        end

        module InstanceMethods
          def collection
            return get_collection_ivar if get_collection_ivar

            set_collection_ivar select_scope

            get_collection_ivar
          end

          def select_scope
            if is_orderable?
              scope_orderable
            else
              scope_default
            end
          end

          def initial_scope
            end_of_association_chain
          end

          def scope_orderable
            initial_scope
              .ordered
          end

          def scope_default
            initial_scope
              .reorder(sort_order)
          end
        end
      end
    end
  end
end
