require_relative 'admin/protected_methods'

module HasCrud
  module ActionController
    module CrudAdminAdditions
      def self.included(base)
        base.send :extend,  ClassMethods
        base.send :include, InstanceMethods
        base.send :include, Admin::ProtectedMethods
        base.send :include, Koi::ApplicationHelper
        base.send :include, ActionView::Helpers::OutputSafetyHelper
        base.send :helper_method, :sort_column, :sort_direction, :page_list,
                  :search_fields, :is_searchable?, :is_sortable?, :is_ajaxable?,
                  :is_exportable?, :title_for, :per_page, :settings_prefix
        base.send :respond_to, :html, :js, :csv
      end

      module ClassMethods
      end

      module InstanceMethods

        def sort
          order = params[singular_name(:symbol)]
          resource_class.orderable(order)
          render :text => nil
        end

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

        def redirect_path
          if params[:commit].eql?("Continue")
            edit_resource_path
          elsif @site_parent || (resource.respond_to?(:resource_nav_item) && resource.resource_nav_item)
            sitemap_nav_items_path
          else
            collection_path
          end
        end

        def per_page
          resource_class.crud.find(:admin, :per_page) || resource_class.options[:paginate]
        end

        def page_list
          resource_class.crud.find(:admin, :page_list) || resource_class.options[:page_list]
        end

      end
    end
  end
end
