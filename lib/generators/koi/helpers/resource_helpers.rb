# frozen_string_literal: true

require_relative "attribute_types"

module Koi
  module Helpers
    module ResourceHelpers
      extend ActiveSupport::Concern

      included do
        include Rails::Generators::ResourceHelpers

        def controller_class_path
          ["admin"] + super
        end
      end

      private

      def archivable?
        model_class&.included_modules&.include?(Koi::Model::Archivable)
      end

      def orderable?
        attributes_names.include?("ordinal")
      end

      def paginate?
        !orderable?
      end

      def selectable?
        archivable?
      end

      def query?
        true
      end

      def admin_index_helper(type: :path)
        "#{plural_route_name}_#{type}"
      end

      def archive_admin_helper(type: :path)
        "archive_#{plural_route_name}_#{type}"
      end

      def archived_admin_helper(type: :path)
        "archived_#{plural_route_name}_#{type}"
      end

      def admin_show_helper(identifier = singular_name, type: :path)
        "#{singular_route_name}_#{type}(#{identifier})"
      end

      def edit_admin_helper(identifier = singular_name, type: :path)
        "edit_#{admin_show_helper(identifier, type:)}"
      end

      def new_admin_helper(type: :path)
        "new_#{singular_route_name}_#{type}"
      end

      def order_admin_helper(type: :path)
        "order_#{plural_route_name}_#{type}"
      end

      def restore_admin_helper(type: :path)
        "restore_#{plural_route_name}_#{type}"
      end
    end
  end
end
