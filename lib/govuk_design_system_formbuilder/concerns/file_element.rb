# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module GOVUKDesignSystemFormBuilder
  module Elements
    module FileElement
      extend ActiveSupport::Concern

      using PrefixableArray

      include Traits::Error
      include Traits::Hint
      include Traits::Label
      include Traits::Supplemental
      include Traits::HTMLAttributes
      include Traits::HTMLClasses
      include ActionDispatch::Routing::RouteSet::MountedHelpers

      def html
        Containers::FormGroup.new(*bound, **default_form_group_options(**@form_group)).html do
          safe_join([label_element, preview, hint_element, error_element, file, destroy_element, supplemental_content])
        end
      end

      protected

      def stimulus_controller_actions
        <<~ACTIONS.gsub(/\s+/, " ").freeze
          dragover->#{stimulus_controller}#dragover
          dragenter->#{stimulus_controller}#dragenter
          dragleave->#{stimulus_controller}#dragleave
          drop->#{stimulus_controller}#drop
        ACTIONS
      end

      def stimulus_controller
        nil
      end

      def file
        @builder.file_field(@attribute_name, attributes(@html_attributes))
      end

      def destroy_element
        return if @html_attributes[:optional].blank?

        @builder.fields_for(:"#{@attribute_name}_attachment") do |form|
          form.hidden_field :_destroy, value: false, data: { "#{stimulus_controller}_target" => "destroy" }
        end
      end

      def destroy_element_trigger
        return if @html_attributes[:optional].blank?

        content_tag(:button, "", class: "file-destroy", data: { action: "#{stimulus_controller}#setDestroy" })
      end

      def preview
        ""
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
        add_option(default_file_input_options, :data, :action, "change->#{stimulus_controller}#onUpload")

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
        add_option(form_group_options, :data, :controller, stimulus_controller)
        add_option(form_group_options, :data, :action, stimulus_controller_actions)
        add_option(form_group_options, :data, :"#{stimulus_controller}_mime_types_value",
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
