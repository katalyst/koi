# frozen_string_literal: true

require_relative "attribute_types"

module Koi
  module Helpers
    module ResourceHelpers
      extend ActiveSupport::Concern

      included do
        include Rails::Generators::ResourceHelpers

        private

        def assign_controller_names!(name)
          super
          @controller_class_path = ["admin", *@controller_class_path]
        end

        def controller_class_path
          if options[:model_name] || @controller_class_path
            @controller_class_path
          else
            class_path
          end
        end

        def class_name
          candidate = (class_path + [file_name]).map!(&:camelize).join("::")
          if @controller_class_path && class_path_overlap.any?
            "::#{candidate}"
          else
            candidate
          end
        end

        def singular_route_name
          parts = controller_class_path

          # Gradually remove suffix parts from the prefix if they appear at the beginning of singular_table_name
          (0..parts.count).detect do |n|
            trial = parts.drop(n).join("_")
            return "#{parts.take(n).join('_')}_#{singular_table_name}" if singular_table_name.start_with?(trial)
          end
        end

        def plural_route_name
          parts = controller_class_path

          # Gradually remove suffix parts from the prefix if they appear at the beginning of plural_table_name
          (0..parts.count).detect do |n|
            trial = parts.drop(n).join("_")
            return "#{parts.take(n).join('_')}_#{plural_table_name}" if plural_table_name.start_with?(trial)
          end
        end
      end

      private

      def archivable?
        model_class&.include?(Koi::Model::Archivable)
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

      def sortable?
        default_sort_attribute.present?
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

      def class_path_overlap(controller = controller_class_path, model = class_path)
        return [] unless controller.present? && model.present?

        limit = [controller.size, model.size].min

        (1..limit).reverse_each do |size|
          return model.slice(0...size) if controller.slice((size - 1)..-1) == model.slice(0...size)
        end

        []
      end
    end
  end
end
