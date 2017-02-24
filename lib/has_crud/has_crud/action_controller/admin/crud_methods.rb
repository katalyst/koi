require_relative 'common_methods'

module HasCrud
  module ActionController
    module Admin
      module CrudMethods

        def self.included(base)
          base.send :include, InstanceMethods
          base.send :include, Admin::CommonMethods
        end

        module ClassMethods
        end

        module InstanceMethods

          def is_allowed?(action)
            actions = [:index, :new, :edit, :destroy]
            actions = (resource_class.crud.find(:admin, :actions, :only) ||
                       (actions - Array(resource_class.crud.find(:admin, :actions, :except)).flatten))
            Array(actions).flatten.include? action
          end

          def per_page
            resource_class.crud.find(:admin, :per_page) || resource_class.options[:paginate]
          end

          def page_list
            resource_class.crud.find(:admin, :page_list) || resource_class.options[:page_list]
          end

          def is_paginated?
            !!per_page
          end

          def is_orderable?
            resource_class.options[:orderable]
          end

          def is_sortable?
            resource_class.options[:sortable]
          end

          def search_fields
            resource_class.options[:searchable]
          end

          def is_searchable?
            !!search_fields
          end

          def is_exportable?
            resource_class.options[:exportable]
          end

          def is_ajaxable?
            resource_class.options[:ajaxable]
          end

          def sort
            ordered_ids = params[singular_name(:symbol)]
            collection.orderable(ordered_ids)
            render text: nil
          end

          # FIXME: Imporve the sorting based on methods
          def sort_column
            resource_class.column_names.include?(params[:sort]) ? params[:sort] : default_sort_column
          end

          def default_sort_column
            resource_class.crud.find(:admin, :index, :order).try(:keys).try(:first) || "id"
          end

          def sort_direction
            %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
          end

          def default_sort_direction
            resource_class.crud.find(:admin, :index, :order).try(:values).try(:first) || "asc"
          end

          def sort_order
            "#{sort_column} #{sort_direction}"
          end

          def parent_title
            respond_to?(:parent) ? "#{humanized(parent)}: " : ""
          end

          def index_title
            parent_title << kt(default: resource_class.crud.find(:admin, :index, :title)\
             || "All #{humanized_plural_name}")
          end

          def action_new_title
            kt(default: resource_class.crud.find(:admin, :form, :title, :new)\
             || "Add #{humanized_singular_name}")
          end

          def new_title
            parent_title << action_new_title
          end

          def edit_title
            parent_title << kt(default: resource_class.crud.find(:admin, :form, :title, :edit)\
             || "Edit #{resource}")
          end

          def action_csv_title
            parent_title << kt(default: resource_class.crud.find(:admin, :csv, :title) || "Download CSV")
          end

          def title_for(symbol=nil)
            method_name = "#{symbol}_title".to_sym
            if respond_to? method_name
              send(method_name)
            else
              "No title defined for #{symbol}"
            end
          end

        end

      end
    end
  end
end
