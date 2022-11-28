# frozen_string_literal: true

require_relative "admin/collection_methods"
require_relative "admin/crud_methods"

module HasCrud
  module ActionController
    module CrudAdminAdditions
      def self.included(base)
        base.send :extend,  ClassMethods
        base.send :include, InstanceMethods
        base.send :include, Admin::CollectionMethods
        base.send :has_scope, :search, if:     :is_searchable?,
                                       except: %i[create update destroy] do |_controller, scope, value|
          scope.search_for(value)
        end
        base.send :include, Admin::CrudMethods
        base.send :include, Koi::ApplicationHelper
        base.send :include, ActionView::Helpers::OutputSafetyHelper
        base.send :helper_method, :sort_column, :sort_direction, :page_list,
                  :search_fields, :is_searchable?, :is_sortable?, :is_ajaxable?,
                  :is_exportable?, :title_for, :per_page, :settings_prefix
        base.send :respond_to, :html, :js, :csv
        base.send :before_action, :allow_all_parameters!
      end

      module ClassMethods
      end

      module InstanceMethods
        def create
          create! do |success, failure|
            success.html { redirect_to redirect_path }
            failure.html { render :new, status: :unprocessable_entity }
          end
        end

        def update
          update! do |success, failure|
            success.html { redirect_to redirect_path }
            failure.html { render :edit, status: :unprocessable_entity }
          end
        end

        private

        def allow_all_parameters!
          params.permit!
        end

        def redirect_path
          if params[:commit].eql?("Continue")
            edit_resource_path
          else
            collection_path
          end
        end

        def create_resource(object)
          if (result = object.save) && (respond_to? :parent)
            # FIXME: hacky way to handle associations
            parent.send(plural_name.to_sym) << object
          end
          result
        end

        def update_resource(object, attributes)
          object.update(*attributes)
        end
      end
    end
  end
end
