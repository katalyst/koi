# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module GOVUKDesignSystemFormBuilder
  module Elements
    class Document < Base
      include FileElement

      def initialize(builder, object_name, attribute_name, hint:, label:, caption:, form_group:, mime_types:,
                     **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @mime_types      = mime_types
        @label           = label
        @caption         = caption
        @hint            = hint
        @html_attributes = kwargs.merge(file_input_options)
        @form_group      = form_group
      end

      def preview
        options = {}
        add_option(options, :data, "#{stimulus_controller}_target", "preview")
        add_option(options, :class, "preview-file")
        add_option(options, :class, "hidden") unless preview?

        tag.div(**options) do
          filename = @builder.object.send(@attribute_name).filename.to_s
          tag.p(filename, class: "preview-filename") + destroy_element_trigger
        end
      end

      private

      def stimulus_controller
        "document-field"
      end

      def form_group_class
        "govuk-document-field"
      end
    end
  end
end

module GOVUKDesignSystemFormBuilder
  module Builder
    delegate :config, to: GOVUKDesignSystemFormBuilder

    # Generates a +div+ element with an +input+ with +type=file+ with a label, optional hint.
    #
    # @example A upload field with label as a proc
    #   = f.govuk_document_field :data, label: -> { tag.h3('Upload your document') }
    #
    def govuk_document_field(attribute_name,
                             label: {},
                             caption: {},
                             hint: {},
                             form_group: {},
                             mime_types: Koi.config.document_mime_types,
                             **kwargs,
                             &block)
      Elements::Document.new(
        self, object_name, attribute_name, label:, caption:, hint:, form_group:, mime_types:, **kwargs, &block
      ).html
    end
  end
end
