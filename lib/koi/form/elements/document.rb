# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module Koi
  module Form
    module Elements
      class Document < GOVUKDesignSystemFormBuilder::Base
        include FileElement

        def initialize(builder, object_name, attribute_name, hint:, label:, caption:, form_group:, mime_types:,
                       **kwargs, &)
          super(builder, object_name, attribute_name, &)

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
end
