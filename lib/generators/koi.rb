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
        field_type    = guess_field_type(attr.name, attr.type)
        whitespace    = whitespace_for_field(attr)
        field_name    = attr.name.chomp('_uid').chomp('_id')
        is_last_field = index === @model_attributes.length-1
        "#{field_name}:#{whitespace} #{field_type}#{',' unless is_last_field}\n\s\s\s\s\s\s\s\s\s\s\s"
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
        elsif field_is_association?(name, data_type)
          "{ type: :association }"
        elsif data_type == 'date'
          '{ type: :date }'
        elsif data_type == 'datetime'
          '{ type: :datetime }'
        else
          '{ type: :string }'
        end
      end

      def field_is_enum?(name, data_type)
        data_type == 'integer' && (name.include?('status') || name.include?('type'))
      end

      def field_is_image?(name, data_type)
        name.include?('_uid') && image_names.any?{ |image_name| name.include?(image_name) }
      end

      def field_is_file?(name, data_type)
        name.include?('_uid') && doc_names.any?{ |doc_name| name.include?(doc_name) }
      end

      def field_is_url?(name, data_type)
        name.include?('url') || name.include?('link')
      end

      def field_is_association?(name, data_type)
        name.include?('_id')
      end

      # for keeping whitespace nice in form field type generation
      # e.g.
      #          something: { type: string },
      #          file:      { type: :file },
      #          my_url:    { type: :string }
      def whitespace_for_field(attr)
        longest_attribute_name = @model_attributes.max_by{ |attr| attr.name.chomp('_uid').length }.name.chomp('_uid')
        current_attribute_name = attr.name.chomp('_uid')
        whitespace_needed      = longest_attribute_name.length - current_attribute_name.length
        "\s" * whitespace_needed
      end

      def crud_field_list
        @model_attributes.map{|attr| attr.name.chomp('_uid').chomp('_id').to_sym }
      end

      def crud_csv_field_list
        #reject fields that are files or images and collects the attribute names
        @model_attributes.reject{ |attr| field_is_image?(attr.name, attr.type) || field_is_file?(attr.name, attr.type) }
                         .map{ |attr| attr.name.chomp('_id').to_sym }
      end

      def image_names
        ['image', 'banner', 'thumb', 'logo', 'tile']
      end

      def doc_names
        ['file', 'document', 'pdf', 'attachment']
      end

      def file_attributes
        @model_attributes.select{ |attr| field_is_file?(attr.name, attr.type) }
      end

      def image_attributes
        @model_attributes.select{ |attr| field_is_image?(attr.name, attr.type) }
      end

      # dragonfly accessors and validation for images/files, validation for urls, enum for statuses
      def make_field_config(attr)
        if field_is_enum?(attr.name, attr.type)
         "#{attr.name.pluralize.upcase} = { active: 'Active', inactive: 'Inactive' }\n\s\s" \
         "enum #{attr.name}: #{attr.name.pluralize.upcase}.keys\n\s\s" \
         "validates :#{attr.name}, presence: true\n\n"
        elsif field_is_image?(attr.name, attr.type)
         "dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :image\n\s\s" \
         "validates_property :format, of: :#{attr.name.chomp('_uid')}, in: ['jpeg', 'png', 'gif', 'png']\n\n"
        elsif field_is_file?(attr.name, attr.type)
         "dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :file\n\s\s" \
         "validates_property :ext, of: :#{attr.name.chomp('_uid')}, in: ['pdf', 'doc', 'docx', 'csv', 'txt']\n\n"
        elsif field_is_url?(attr.name, attr.type)
         "validates :#{attr.name}, format: { with: URI::regexp, message: \"must be a valid url (including http:// or https://)\" }\n"
        elsif field_is_association?(attr.name, attr.type)
          "belongs_to :#{attr.name.chomp('_id')}\n\n"
        else
          ""
        end
      end

    end
  end
end
