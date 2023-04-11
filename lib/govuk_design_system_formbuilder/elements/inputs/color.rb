# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module GOVUKDesignSystemFormBuilder
  module Elements
    module Inputs
      class Color < Base
        include Traits::Input
        include Traits::Error
        include Traits::Hint
        include Traits::Label
        include Traits::Supplemental
        include Traits::HTMLAttributes

        private

        def builder_method
          :color_field
        end
      end
    end
  end
end

module GOVUKDesignSystemFormBuilder
  module Builder
    delegate :config, to: GOVUKDesignSystemFormBuilder

    # Generates a input of type +color+
    #
    # @param attribute_name [Symbol] The name of the attribute
    # @param hint [Hash,Proc] The content of the hint. No hint will be added if 'text' is left +nil+. When a +Proc+ is
    #   supplied the hint will be wrapped in a +div+ instead of a +span+
    # @option hint text [String] the hint text
    # @option hint kwargs [Hash] additional arguments are applied as attributes to the hint
    #
    # @param width [Integer,String] sets the width of the input, can be +2+, +3+ +4+, +5+, +10+ or +20+ characters
    #   or +one-quarter+, +one-third+, +one-half+, +two-thirds+ or +full+ width of the container
    # @param label [Hash,Proc] configures or sets the associated label content
    # @option label text [String] the label text
    # @option label size [String] the size of the label font, can be +xl+, +l+, +m+, +s+ or nil
    # @option label tag [Symbol,String] the label's wrapper tag, intended to allow labels to act as page headings
    # @option label hidden [Boolean] control the visibility of the label
    #   Hidden labels will still be read by screen-readers
    # @option label kwargs [Hash] additional arguments are applied as attributes on the +label+ element
    # @param caption [Hash] configures or sets the caption content which is inserted above the label
    # @option caption text [String] the caption text
    # @option caption size [String] the size of the caption, can be +xl+, +l+ or +m+. Defaults to +m+
    # @option caption kwargs [Hash] additional arguments are applied as attributes on the caption +span+ element
    # @option kwargs [Hash] kwargs additional arguments are applied as attributes to the +input+ element
    # @param form_group [Hash] configures the form group
    # @option form_group classes [Array,String] sets the form group's classes
    # @option form_group kwargs [Hash] additional attributes added to the form group
    # @param prefix_text [String] the text placed before the input. No prefix will be added if left +nil+
    # @param suffix_text [String] the text placed after the input. No suffix will be added if left +nil+
    # @param block [Block] arbitrary HTML that will be rendered between the hint and the input
    # @return [ActiveSupport::SafeBuffer] HTML output
    #
    # @example A required color field with a placeholder
    #   = f.govuk_color_field :name,
    #     label: { text: 'Color' },
    #     required: true,
    #     placeholder: 'Choose a color'
    #
    def govuk_color_field(attribute_name, hint: {}, label: {}, caption: {}, width: nil, form_group: {},
                          prefix_text: nil, suffix_text: nil, **kwargs, &block)
      Elements::Inputs::Color.new(self, object_name, attribute_name, hint:, label:, caption:, width:,
                                  form_group:, prefix_text:, suffix_text:, **kwargs, &block).html
    end
  end
end
