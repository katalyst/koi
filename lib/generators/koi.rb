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
            @model_attributes << Rails::Generators::GeneratedAttribute.parse(arg)
          end
        end
      end

      #make the field type for crud
      # i.e. banner_image: { type: :image }
      def make_field_type(attr, index)
        field_type    = guess_field_type(attr)
        whitespace    = whitespace_for_field(attr)
        field_name    = attr.name.chomp('_uid').chomp('_id')
        is_last_field = index === @model_attributes.length-1
        "#{field_name}:#{whitespace} #{field_type}#{',' unless is_last_field}#{' # override this' if attr.polymorphic?}\n\s\s\s\s\s\s\s\s\s\s\s"
      end

      def guess_field_type(attr)
        if field_is_rich_text?(attr)
          '{ type: :rich_text }'
        elsif field_is_image?(attr)
          '{ type: :image }'
        elsif field_is_file?(attr)
          '{ type: :file }'
        elsif field_is_enum?(attr)
          "{ type: :select, data: #{attr.name.pluralize.upcase}.invert }"
        elsif field_is_association?(attr)
          "{ type: :association }"
        elsif attr.type == :boolean
          '{ type: :boolean }'
        elsif attr.type == :date
          '{ type: :date }'
        elsif attr.type == :datetime
          '{ type: :datetime }'
        else
          '{ type: :default }'
        end
      end

      def field_is_rich_text?(attr)
        attr.type == :text && attr.name.exclude?('embed') && attr.name.exclude?('short')
      end

      def field_is_enum?(attr)
        attr.type == :integer && (attr.name.include?('status') || attr.name.include?('type'))
      end

      def field_is_image?(attr)
        attr.name.include?('_uid') && image_names.any?{ |image_name| attr.name.include?(image_name) }
      end

      def field_is_file?(attr)
        attr.name.include?('_uid') && doc_names.any?{ |doc_name| attr.name.include?(doc_name) }
      end

      def field_is_url?(attr)
        attr.name.include?('url') || attr.name.include?('link')
      end

      def field_is_association?(attr)
        attr.name.include?('_id') || attr.reference?
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
        @model_attributes.reject(&:polymorphic?)
                         .map{|attr| attr.name.chomp('_uid').chomp('_id').to_sym }
      end

      def crud_csv_field_list
        #reject fields that are files or images and collects the attribute names
        @model_attributes.reject{ |attr| field_is_image?(attr) || field_is_file?(attr) }
                         .map{ |attr| attr.name.chomp('_id').to_sym }
      end

      def image_names
        ['image', 'banner', 'thumb', 'logo', 'tile']
      end

      def doc_names
        ['file', 'document', 'pdf', 'attachment']
      end

      def file_attributes
        @model_attributes.select{ |attr| field_is_file?(attr) }
      end

      def image_attributes
        @model_attributes.select{ |attr| field_is_image?(attr) }
      end


      #
      # RENDER METHODS FOR FIELD CONFIG
      #
      # these methods are used to generate dragonfly accessors, validation for images/files,
      # validation for urls/booleans, enum for statuses, and belongs_to associations
      #

      def render_enums
        # get likely enum attributes
        enums = model_attributes.select{ |attr| field_is_enum?(attr) }

        # for each enum, create a constant, an enum field, and validation
        enums.map{ |attr|
          <<-code
  #{attr.name.pluralize.upcase} = { active: 'Active', inactive: 'Inactive' }
  enum #{attr.name}: #{attr.name.pluralize.upcase}.keys
  validates :#{attr.name}, presence: true

          code
        }.join
      end

      def render_images
        images = model_attributes.select{ |attr| field_is_image?(attr) }
        images.map{ |attr|
          <<-code
  dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :image
  validates_property :format, of: :#{attr.name.chomp('_uid')}, in: ['jpeg', 'png', 'gif', 'png']

          code
        }.join
      end

      def render_files
        files = model_attributes.select{ |attr| field_is_file?(attr) }
        files.map{ |attr|
          <<-code
  dragonfly_accessor :#{attr.name.chomp('_uid')}, app: :file
  validates_property :ext, of: :#{attr.name.chomp('_uid')}, in: ['pdf', 'doc', 'docx', 'csv', 'txt']

          code
        }.join
      end

      def render_urls
        # get likely url fields
        urls = model_attributes.select{ |attr| field_is_url?(attr) }
        urls.map{ |attr|
          <<-code
  validates :#{attr.name}, format: { with: URI::regexp, message: \"must be a valid url (including http:// or https://)\" }

          code
        }.join
      end

      def render_associations
        associations = model_attributes.select{ |attr| field_is_association?(attr) }
        associations.map{ |attr|
          <<-code
  belongs_to :#{attr.name.chomp('_id')}#{", polymorphic: true" if attr.polymorphic?}

          code
        }.join
      end

      def render_booleans
        booleans = model_attributes.select{ |attr| attr.type.eql?('boolean') }
        booleans.map{ |attr|
          <<-code
  validates :#{attr.name}, inclusion: { in: [true, false], message: "Can't be blank" }

          code
        }.join
      end

      #
      # END FIELD CONFIG RENDER METHODS
      #


    end
  end
end
