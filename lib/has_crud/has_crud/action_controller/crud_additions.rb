# frozen_string_literal: true

module HasCrud
  module ActionController
    module CrudAdditions
      def self.included(base)
        base.send :extend,  ClassMethods
        base.send :include, InstanceMethods
        base.send :include, Koi::ApplicationHelper
        base.send :inherit_resources
        base.send :attr_accessor, :path
        base.send :helper_method, :is_allowed?, :is_orderable?, :is_paginated?,
                  :singular_name, :plural_name, :path, :crud_partial
        base.send :has_scope, :page, default: 1, if: :is_paginated?,
                                     except: %i[create update destroy] do |controller, scope, value|
          scope.page(value).per(controller.per_page)
        end
        base.send :has_scope, :per, if:     :is_paginated?,
                                    except: %i[create update destroy] do |controller, scope, value|
          value.to_i.eql?(0) ? scope.per(controller.per_page) : scope.per(value)
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def has_crud?
          true
        end

        def singular_name(to_sym = false)
          name = resource_class.to_s.underscore
          to_sym ? name : name.to_sym
        end

        def plural_name(to_sym = false)
          name = singular_name(:symbol).pluralize
          to_sym ? name : name.to_sym
        end

        def is_allowed?(action)
          actions = %i[index show new edit destroy]
          actions = (resource_class.crud.find(:actions, :only) ||
                     (actions - Array(resource_class.crud.find(:actions, :except)).flatten))
          Array(actions).flatten.include? action
        end

        def per_page
          resource_class.crud.find(:per_page) || resource_class.options[:paginate]
        end

        def is_paginated?
          request.format == :csv ? false : !!per_page
        end

        def is_orderable?
          resource_class.options[:orderable]
        end

        def collection
          return get_collection_ivar if get_collection_ivar

          set_collection_ivar end_of_association_chain.send(is_orderable? ? :ordered : :all)
          get_collection_ivar
        end

        def crud_partial(attr, path, klass = resource_class)
          partial = klass.crud.find(:fields, attr, :type)
          "#{path}_field_#{partial}"
        end
      end
    end
  end
end
