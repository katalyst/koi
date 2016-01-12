require 'rails/generators/base'

module Koi
  module Generators
    class Base < Rails::Generators::Base #:nodoc:

      def self.source_root
        @_koi_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'koi', generator_name, 'templates'))
      end

      def self.banner
        "rails generate koi:#{generator_name} #{self.arguments.map{ |a| a.usage }.join(' ')} [options]"
      end

      private

      def add_gem(name, options = {})
        gemfile_content = File.read(destination_path("Gemfile"))
        File.open(destination_path("Gemfile"), 'a') { |f| f.write("\n") } unless gemfile_content =~ /\n\Z/
        gem name, options unless gemfile_content.include? name
      end

      def print_usage
        self.class.help(Thor::Base.shell.new)
        exit
      end

      def process_attributes
        args_for_c_m.each do |arg|
          if arg.include?(':')
            @model_attributes << Rails::Generators::GeneratedAttribute.new(*arg.split(':'))
          end
        end
      end

      #make the field type for crud
      # i.e. banner_image: { type: :image }
      def make_field_type(attr, index)
        "#{attr.name.chomp('_uid')}:#{whitespace_for_field(attr)} #{guess_field_type(attr.name, attr.type)}#{',' if index != @model_attributes.length-1}\n\s\s\s\s\s\s\s\s\s\s\s"
      end

      def guess_field_type(name, data_type)
        if data_type == 'text'
          '{ type: :rich_text }'
        elsif field_is_image?(name, data_type)
          '{ type: :image }'
        elsif field_is_file?(name, data_type)
          '{ type: :file }'
        elsif data_type == 'boolean'
          '{ type: :boolean }'
        elsif field_is_enum?(name, data_type)
          "{ type: :select, data: #{name.pluralize.upcase}.invert }"
        else
          '{ type: :string }'
        end
      end

      def field_is_enum?(name, data_type)
        data_type == 'integer' && name.include?('status')
      end

      def field_is_image?(name, data_type)
        name.include?('_uid') && image_names.any?{ |image_name| name.include?(image_name) }
      end

      def field_is_file?(name, data_type)
        name.include?('_uid') && doc_names.any?{ |doc_name| name.include?(doc_name) }
      end

      #for keeping whitespace nice in form field type generation
      def whitespace_for_field(attr)
        "\s"*(@model_attributes.max_by{|attr|attr.name.chomp('_uid').length}.name.chomp('_uid').length-attr.name.chomp('_uid').length)
      end

      def crud_field_list
        @model_attributes.map{|attr| attr.name.chomp('_uid').to_sym }
      end

      def crud_csv_field_list
        #reject fields that are files or images
        @model_attributes.reject{ |attr| field_is_image?(attr.name, attr.type) || field_is_file?(attr.name, attr.type) }
                         .map{ |attr| attr.name.to_sym }
      end

      def image_names
        ['image', 'banner', 'thumb', 'logo', 'tile']
      end

      def doc_names
        ['file', 'document', 'pdf', 'attachment']
      end

    end
  end
end
