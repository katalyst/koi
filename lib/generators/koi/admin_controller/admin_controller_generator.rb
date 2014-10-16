require 'generators/koi'
require 'rails/generators/migration'
require 'rails/generators/active_record'
require 'rails/generators/generated_attribute'
module Koi
  module Generators
    class AdminControllerGenerator < Base

      include Rails::Generators::Migration
      no_tasks { attr_accessor :scaffold_name, :model_attributes }

      argument :scaffold_name, :type => :string, :required => true, :banner => 'ModelName'
      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :skip_model,      :desc => 'Don\'t generate a model or migration file.', :type => :boolean
      class_option :skip_serializer, :desc => 'Don\'t generate a serializer.', :type => :boolean
      class_option :skip_migration,  :desc => 'Dont generate migration file for model.', :type => :boolean

      class_option :versioned, :desc => 'Add versioning capabilities.', :group => 'Additional Options', :type => :boolean
      class_option :orderable, :desc => 'Add Drag n Drop ordering capabilities.', :group => 'Additional Options', :type => :boolean

      def initialize(*args, &block)
        super

        print_usage unless scaffold_name.underscore =~ /^[a-z][a-z0-9_\/]+$/

        @model_attributes = []
        @skip_model = options.skip_model?

        @versioned = options.versioned?
        @orderable = options.orderable?

        process_attributes

        @model_attributes.uniq!

        if @model_attributes.empty?
          @skip_model = true # skip model if no attributes
        end
      end

      def create_model
        unless @skip_model
          template 'model_template.rb', "app/models/#{model_path}.rb"
        end
      end

      def create_serializer
        unless @skip_serializer
          template 'serializer_template.rb', "app/serializers/#{model_path}_serializer.rb"
        end
      end

      def create_koi_migration
        unless @skip_model || options.skip_migration?
          migration_template 'migration_template.rb', "db/migrate/create_#{model_path.pluralize.gsub('/', '_')}.rb"
        end
      end

      def create_controller
        unless options.skip_controller?
          template 'controller_template.rb', "app/controllers/admin/#{plural_name}_controller.rb"

          namespaces = ['admin', plural_name]
          resource = namespaces.pop
          route namespaces.reverse.inject("resources :#{resource}") { |acc, namespace|
            "namespace(:#{namespace}) { #{acc} }"
          }

          if @orderable
            puts
            puts "Add the sort action to the route:"
            puts
            puts "  namespace(:admin) do"
            puts "    resources :#{plural_name} do"
            puts "      collection { put 'sort' }"
            puts "    end"
            puts "  end"
            puts
          end
        end
      end

      private

      def singular_name
        scaffold_name.underscore
      end

      def plural_name
        scaffold_name.underscore.pluralize
      end

      def table_name
        plural_name.split('/').last
      end

      def class_name
        if @namespace_model
          scaffold_name.camelize
        else
          scaffold_name.split('::').last.camelize
        end
      end

      def plural_class_name
        plural_name.camelize
      end

      def instance_name
        if @namespace_model
          singular_name.gsub('/','_')
        else
          singular_name.split('/').last
        end
      end

      def instances_name
        instance_name.pluralize
      end

      def model_path
        class_name.underscore
      end

      def model_columns_for_attributes
        class_name.constantize.columns.reject do |column|
          column.name.to_s =~ /^(id|created_at|updated_at)$/
        end
      end

      def model_exists?
        File.exist? destination_path("app/models/#{singular_name}.rb")
      end

      def read_template(relative_path)
        ERB.new(File.read(find_in_source_paths(relative_path)), nil, '-').result(binding)
      end

      def destination_path(path)
        File.join(destination_root, path)
      end

      def self.next_migration_number(dirname)
        ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

    end
  end
end
