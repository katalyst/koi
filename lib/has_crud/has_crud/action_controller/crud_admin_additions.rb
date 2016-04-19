require_relative 'admin/collection_methods'
require_relative 'admin/crud_methods'

module HasCrud
  module ActionController
    module CrudAdminAdditions
      def self.included(base)
        base.send :extend,  ClassMethods
        base.send :include, InstanceMethods
        base.send :include, Admin::CollectionMethods
        base.send :has_scope, :search, :if => :is_searchable?,
                  :except => [ :create, :update, :destroy ] do |controller, scope, value|
          scope.search_for(value)
        end
        base.send :include, Admin::CrudMethods
        base.send :include, Koi::ApplicationHelper
        base.send :include, ActionView::Helpers::OutputSafetyHelper
        base.send :helper_method, :sort_column, :sort_direction, :page_list,
                  :search_fields, :is_searchable?, :is_sortable?, :is_ajaxable?,
                  :is_exportable?, :title_for, :per_page, :settings_prefix
        base.send :respond_to, :html, :js, :csv
        base.send :before_filter, :allow_all_parameters!
      end

      module ClassMethods
      end

      module InstanceMethods

        def create
          create! do |success, failure|
            success.html { redirect_to redirect_path }
          end
        end

        def update
          update! do |success, failure|
            success.html { redirect_to redirect_path }
          end
        end

        private

          def allow_all_parameters!
            params.permit!
          end

          def redirect_path
            if params[:commit].eql?("Continue")
              edit_resource_path
            elsif @site_parent || (resource.respond_to?(:resource_nav_item) && resource.resource_nav_item)
              sitemap_nav_items_path
            else
              collection_path
            end
          end

          def create_resource(object)
            @site_parent = params[:site_parent] if params[:site_parent].present?
            result = object.save
            if result
              #FIXME: hacky way to handle associations
              parent.send(plural_name.to_sym) << object if respond_to? :parent
              object.to_navigator!(parent_id: params[:site_parent]) if object.respond_to? :to_navigator
            end
            result
          end

          def update_resource(object, attributes)
            result = object.update_attributes(*attributes)
            if result
              object.to_navigator! if object.respond_to? :to_navigator
            end
            return result
          end

      end
    end
  end
end
