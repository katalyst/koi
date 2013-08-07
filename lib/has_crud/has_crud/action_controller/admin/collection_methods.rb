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
            elsif is_searchable?
              scope_searchable
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
            .scoped
          end

          def scope_searchable
            initial_scope
            .search_for(params[:search])
            .reorder(sort_order)
            .scoped
          end

          def scope_default
            initial_scope
            .reorder(sort_order)
            .scoped
          end

        end

      end
    end
  end
end
