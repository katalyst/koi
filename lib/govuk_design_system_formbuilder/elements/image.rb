# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module GOVUKDesignSystemFormBuilder
  module Elements
    class Image < Base
      using PrefixableArray

      include Traits::Error
      include Traits::Hint
      include Traits::Label
      include Traits::Supplemental
      include Traits::HTMLAttributes
      include Traits::HTMLClasses
      include ActionDispatch::Routing::RouteSet::MountedHelpers

      IMAGE_FIELD_CONTROLLER = "image-field"
      MIME_TYPES             = %w[image/png image/gif image/jpeg image/webp].freeze

      ACTIONS = <<~ACTIONS.gsub(/\s+/, " ").freeze
        dragover->#{IMAGE_FIELD_CONTROLLER}#dragover
        dragenter->#{IMAGE_FIELD_CONTROLLER}#dragenter
        dragleave->#{IMAGE_FIELD_CONTROLLER}#dragleave
        drop->#{IMAGE_FIELD_CONTROLLER}#drop
      ACTIONS

      def initialize(builder, object_name, attribute_name, hint:, label:, caption:, form_group:, **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @mime_types      = MIME_TYPES || kwargs[:mime_types]
        @label           = label
        @caption         = caption
        @hint            = hint
        @html_attributes = kwargs.merge(file_input_options)
        @form_group      = form_group
      end

      def html
        Containers::FormGroup.new(*bound, **default_form_group_options(**@form_group)).html do
          safe_join([label_element, preview, hint_element, error_element, file, destroy_element, supplemental_content])
        end
      end

      private

      def file
        @builder.file_field(@attribute_name, attributes(@html_attributes))
      end

      def destroy_element
        return if @html_attributes[:optional].blank?

        @builder.fields_for(:"#{@attribute_name}_attachment") do |form|
          form.hidden_field :_destroy, value: false, data: { "#{IMAGE_FIELD_CONTROLLER}_target" => "destroyImage" }
        end
      end

      def destroy_element_trigger
        return if @html_attributes[:optional].blank?

        content_tag(:button, "", class: "image-destroy", data: { action: "#{IMAGE_FIELD_CONTROLLER}#setDestroy" })
      end

      def preview
        options = {}
        add_option(options, :data, "#{IMAGE_FIELD_CONTROLLER}_target", "preview")
        add_option(options, :class, "preview-image")
        add_option(options, :class, "hidden") unless preview?

        tag.div **options do
          tag.img(src: preview_url, class: "image-thumbnail") + destroy_element_trigger
        end
      end

      def preview_url
        preview? ? main_app.url_for(value) : ""
      end

      def preview?
        value&.attached? && value&.persisted?
      end

      def value
        @builder.object.send(@attribute_name)
      end

      def file_input_options
        default_file_input_options = options

        add_option(default_file_input_options, :accept, @mime_types.join(","))
        add_option(default_file_input_options, :data, :action, "change->#{IMAGE_FIELD_CONTROLLER}#onUpload")

        default_file_input_options
      end

      def options
        {
          id:    field_id(link_errors: true),
          class: classes,
          aria:  { describedby: combine_references(hint_id, error_id, supplemental_id) },
        }
      end

      def classes
        build_classes(%(file-upload), %(file-upload--error) => has_errors?).prefix(brand)
      end

      def default_form_group_options(**form_group_options)
        add_option(form_group_options, :class, "govuk-form-group govuk-image-field")
        add_option(form_group_options, :data, :controller, IMAGE_FIELD_CONTROLLER)
        add_option(form_group_options, :data, :action, ACTIONS)
        add_option(form_group_options, :data, :"#{IMAGE_FIELD_CONTROLLER}_mime_types_value",
                   @mime_types.to_json)

        form_group_options
      end

      def add_option(options, key, *path)
        if path.length > 1
          add_option(options[key] ||= {}, *path)
        else
          options[key] = [options[key], *path].compact.join(" ")
        end
      end
    end
  end
end

module GOVUKDesignSystemFormBuilder
  module Builder
    delegate :config, to: GOVUKDesignSystemFormBuilder

    # Generates a +div+ element to preview uploaded images and an +input+ with +type=file+ with a label, optional hint.
    #
    # @param attribute_name [Symbol] The name of the attribute
    # @param hint [Hash,Proc] The content of the hint. No hint will be added if 'text' is left +nil+. When a +Proc+ is
    #   supplied the hint will be wrapped in a +div+ instead of a +span+
    # @option hint text [String] the hint text
    # @option hint kwargs [Hash] additional arguments are applied as attributes to the hint
    # @param label [Hash,Proc] configures or sets the associated label content
    # @option label text [String] the label text
    # @option label size [String] the size of the label font, can be +xl+, +l+, +m+, +s+ or nil
    # @option label tag [Symbol,String] the label's wrapper tag, intended to allow labels to act as page headings
    # @option label hidden [Boolean] control the visibility of the label. Hidden labels will still be read by screen
    #   readers
    # @option label kwargs [Hash] additional arguments are applied as attributes on the +label+ element
    # @param caption [Hash] configures or sets the caption content which is inserted above the label
    # @option caption text [String] the caption text
    # @option caption size [String] the size of the caption, can be +xl+, +l+ or +m+. Defaults to +m+
    # @option caption kwargs [Hash] additional arguments are applied as attributes on the caption +span+ element
    # @option kwargs [Hash] kwargs additional arguments are applied as attributes to the +input+ element.
    # @param form_group [Hash] configures the form group
    # @option form_group classes [Array,String] sets the form group's classes
    # @option form_group kwargs [Hash] additional attributes added to the form group
    # @param block [Block] arbitrary HTML that will be rendered between the hint and the input
    # @return [ActiveSupport::SafeBuffer] HTML output
    #
    # @example An image field with injected content
    #   = f.govuk_image_field :incident_image,
    #     label: { text: 'Attach a picture of the incident' } do
    #
    #     p.govuk-inset-text
    #       | If you don't know exactly leave this section blank
    #
    # @example A image upload field with label as a proc
    #   = f.govuk_image_field :image, label: -> { tag.h3('Upload your image') }
    #
    def govuk_image_field(attribute_name, label: {}, caption: {}, hint: {}, form_group: {}, **kwargs, &block)
      Elements::Image.new(self, object_name, attribute_name, label: label, caption: caption, hint: hint, form_group: form_group, **kwargs, &block).html
    end
  end
end
