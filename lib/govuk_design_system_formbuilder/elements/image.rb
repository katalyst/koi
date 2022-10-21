# frozen_string_literal: true

require "govuk_design_system_formbuilder"
require "govuk_design_system_formbuilder/elements/document"

module GOVUKDesignSystemFormBuilder
  module Elements
    class Image < Base
      include FileElement

      MIME_TYPES = %w[image/png image/gif image/jpeg image/webp].freeze

      def initialize(builder, object_name, attribute_name, hint:, label:, caption:, form_group:, **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @mime_types      = MIME_TYPES || kwargs[:mime_types]
        @label           = label
        @caption         = caption
        @hint            = hint
        @html_attributes = kwargs.merge(file_input_options)
        @form_group      = form_group
      end

      def preview
        options = {}
        add_option(options, :data, "#{stimulus_controller}_target", "preview")
        add_option(options, :class, "preview-image")
        add_option(options, :class, "hidden") unless preview?

        tag.div **options do
          tag.img(src: preview_url, class: "image-thumbnail") + destroy_element_trigger
        end
      end

      def stimulus_controller
        "image-field"
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
