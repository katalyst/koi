require 'generators/koi'
require 'rails/generators/migration'
require 'rails/generators/generated_attribute'

module Koi
  module Generators
    class ControllerGenerator < Base
      include Rails::Generators::Migration
      no_tasks { attr_accessor :scaffold_name, :model_attributes }

      argument :scaffold_name, :type => :string, :required => true, :banner => 'ModelName'
      argument :args_for_c_m, :type => :array, :default => [], :banner => 'model:attributes'

      class_option :skip_views, :desc => 'Don\'t generate views.', :type => :boolean, :default => false
      class_option :skip_model, :desc => 'Don\'t generate a model or migration file.', :type => :boolean
      class_option :skip_migration, :desc => 'Dont generate migration file for model.', :type => :boolean

      class_option :versioned, :desc => 'Add versioning capabilities.', :group => 'Additional Options', :type => :boolean
      class_option :orderable, :desc => 'Add Drag n Drop ordering capabilities.', :group => 'Additional Options', :type => :boolean

      def initialize(*args, &block)
        super

        print_usage unless scaffold_name.underscore =~ /^[a-z][a-z0-9_\/]+$/

        @skip_views = options.skip_views?

        @model_attributes = []
        @skip_model = options.skip_model?

        @versioned = options.versioned?
        @orderable = options.orderable?

        args_for_c_m.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          end
        end

        @model_attributes.uniq!

        if @model_attributes.empty?
          @skip_model = true
        end
      end

      def create_model
        unless @skip_model
          template 'model_template.rb', "app/models/#{model_path}.rb"
        end
      end

      def create_migration
        unless @skip_model || options.skip_migration?
          migration_template 'migration_template.rb', "db/migrate/create_#{model_path.pluralize.gsub('/', '_')}.rb"
        end
      end

      def create_controller
        unless options.skip_controller?
          template 'controller_template.rb', "app/controllers/#{plural_name}_controller.rb"

          create_views unless options.skip_views?

          namespaces = [plural_name]
          resource = namespaces.pop
          route namespaces.reverse.inject("resources :#{resource}") { |acc, namespace|
            "namespace(:#{namespace}) { #{acc} }"
          }
        end
      end

      private

      def create_views
        %w[index show new edit _form].each do |action| # Actions with templates
          template "views/#{action}.html.erb", "app/views/#{plural_name}/#{action}.html.erb"
        end
      end

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

      def item_resource
        scaffold_name.underscore.gsub('/','_')
      end

      def items_path
        "#{item_resource.pluralize}_path"
      end

      def item_path(options = {})
        name = options[:instance_variable] ? "@#{instance_name}" : instance_name
        suffix = options[:full_url] ? "url" : "path"
        if options[:action].to_s == "new"
          "new_#{item_resource}_#{suffix}"
        elsif options[:action].to_s == "edit"
          "edit_#{item_resource}_#{suffix}(#{name})"
        else
          if scaffold_name.include?('::') && !@namespace_model
            namespace = singular_name.split('/')[0..-2]
            "[:#{namespace.join(', :')}, #{name}]"
          else
            name
          end
        end
      end

      def item_url
        items_url
      end

      def items_url
        item_resource.pluralize + '_url'
      end

      def read_template(relative_path)
        ERB.new(File.read(find_in_source_paths(relative_path)), nil, '-').result(binding)
      end

      def destination_path(path)
        File.join(destination_root, path)
      end

      # FIXME: Should be proxied to ActiveRecord::Generators::Base
      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
      end
    end
  end
end
