# frozen_string_literal: true

module Koi
  module Form
    module Elements
      class Image < GOVUKDesignSystemFormBuilder::Base
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
          add_option(options, :class, "preview-image")
          options[:hidden] = "" unless preview?

          tag.div(**options) do
            tag.img(src: preview_url, class: "image-thumbnail") + destroy_element_trigger
          end
        end

        private

        def stimulus_controller
          "image-field"
        end

        def form_group_class
          "govuk-image-field"
        end
      end
    end
  end
end
