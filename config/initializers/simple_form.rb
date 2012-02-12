module SimpleForm

  # This should a div so we can nest multiple paragraphs inside a hint.
  @@hint_tag = :p

  @@hint_class = :small

  @@error_tag = :p

  @@collection_wrapper_tag = :ul
  @@item_wrapper_tag = :li

  mattr_accessor :collection_class
  @@collection_class = "vertical spaced-10px list"

  mattr_accessor :error_notification_partial
  @@error_notification_partial = 'shared/error_notification'

  mattr_accessor :fieldset_legend_tag
  @@fieldset_legend_tag = :h3

  mattr_accessor :label_class
  @@label_class = [ "simple label as-blk tx-bold" ]

  @@wrapper_tag = :div
  @@wrapper_class = [ "simple wrapper as-clr" ]

  module Inputs

    class Base

      # Allows labels to be optionally generated without html options.
      def label(skip_html_options=false)
        @builder.label(label_target, label_text, (skip_html_options ? {} : label_html_options))
      end

      # Fixes label for attributes to point to the correct element.
      def label_html_options
        label_options = html_options_for(:label, [input_type, required_class, SimpleForm.label_class])
        label_options[:for] = options[:input_html][:id] if options.key?(:input_html) && options[:input_html].key?(:id)
        label_options
      end

    end

    class BooleanInput

      # Generate a boolean input without classes on the LABEL tag so it looks like plain text
      # instead of a proper label.
      def label_input
        input + (options[:label] == false ? "" : label(true))
      end

    end

  end

  class ErrorNotification

    # Uses a partial for rendering the error notifications.
    def render
      errors_with_ids = []
      errors.each { |name,message| errors_with_ids << { name: name, message: message, id: "#{object_name}_#{name}" } }
      template.render(:partial => SimpleForm.error_notification_partial, :locals => { :errors => errors_with_ids }) if has_errors? && !SimpleForm.error_notification_partial.blank?
    end

  end

  module ActionViewExtensions

    module Builder

      def render_collection(attribute, collection, value_method, text_method, options={}, html_options={}) #:nodoc:
        collection_wrapper_tag = options.has_key?(:collection_wrapper_tag) ? options[:collection_wrapper_tag] : SimpleForm.collection_wrapper_tag
        item_wrapper_tag = options.has_key?(:item_wrapper_tag) ? options[:item_wrapper_tag] : SimpleForm.item_wrapper_tag

        rendered_collection = collection.map do |item|
          value = value_for_collection(item, value_method)
          text  = value_for_collection(item, text_method)
          default_html_options = default_html_options_for_collection(item, value, options, html_options)

          rendered_item = yield value, text, default_html_options

          item_wrapper_tag ? @template.content_tag(item_wrapper_tag, rendered_item) : rendered_item
        end.join.html_safe

        collection_wrapper_tag ? @template.content_tag(collection_wrapper_tag, rendered_collection, :class => SimpleForm.collection_class) : rendered_collection
      end

    end

  end

end

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Components used by the form builder to generate a complete input. You can remove
  # any of them, change the order, or even add your own components to the stack.
  # config.components = [ :placeholder, :label_input, :hint, :error ]

  # Default tag used on hints.
  # config.hint_tag = :span

  # CSS class to add to all hint tags.
  # config.hint_class = :hint

  # CSS class used on errors.
  # config.error_class = :error

  # Default tag used on errors.
  # config.error_tag = :span

  # Method used to tidy up errors.
  # config.error_method = :first

  # Default tag used for error notification helper.
  # config.error_notification_tag = :p

  # CSS class to add for error notification helper.
  # config.error_notification_class = :error_notification

  # ID to add for error notification helper.
  # config.error_notification_id = nil

  # You can wrap all inputs in a pre-defined tag.
  # config.wrapper_tag = :div

  # CSS class to add to all wrapper tags.
  # config.wrapper_class = :input

  # CSS class to add to the wrapper if the field has errors.
  # config.wrapper_error_class = :field_with_errors

  # You can wrap a collection of radio/check boxes in a pre-defined tag, defaulting to none.
  # config.collection_wrapper_tag = nil

  # You can wrap each item in a collection of radio/check boxes with a tag, defaulting to span.
  # config.item_wrapper_tag = :span

  # Series of attemps to detect a default label method for collection.
  # config.collection_label_methods = [ :to_label, :name, :title, :to_s ]

  # Series of attemps to detect a default value method for collection.
  # config.collection_value_methods = [ :id, :to_s ]

  # How the label text should be generated altogether with the required text.
  # config.label_text = lambda { |label, required| "#{label} #{required}" }

  # You can define the class to use on all labels. Default is nil.
  # config.label_class = nil

  # You can define the class to use on all forms. Default is simple_form.
  # config.form_class = :simple_form

  # Whether attributes are required by default (or not). Default is true.
  # config.required_by_default = true

  # Tell browsers whether to use default HTML5 validations (novalidate option).
  # Default is enabled.
  config.browser_validations = false

  # Determines whether HTML5 types (:email, :url, :search, :tel) and attributes
  # (e.g. required) are used or not. True by default.
  # Having this on in non-HTML5 compliant sites can cause odd behavior in
  # HTML5-aware browsers such as Chrome.
  config.html5 = false

  # Custom mappings for input types. This should be a hash containing a regexp
  # to match as key, and the input type that will be used when the field name
  # matches the regexp as value.
  # config.input_mappings = { /count/ => :integer }

  # Collection of methods to detect if a file type was given.
  # config.file_methods = [ :mounted_as, :file?, :public_filename ]

  # Default priority for time_zone inputs.
  # config.time_zone_priority = nil

  # Default priority for country inputs.
  config.country_priority = [ "Australia" ]
  # config.country_priority = nil

  # Default size for text inputs.
  # config.default_input_size = 50

  # When false, do not use translations for labels, hints or placeholders.
  # config.translate = true

end
