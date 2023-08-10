# frozen_string_literal: true

require "govuk_design_system_formbuilder"

module GOVUKDesignSystemFormBuilder
  module Elements
    class DateTime < Base
      using PrefixableArray

      include Traits::Error
      include Traits::Hint
      include Traits::Supplemental
      include Traits::HTMLClasses

      SEGMENTS           = { day: "3i", month: "2i", year: "1i", hour: "4i", minute: "5i", offset: "8i" }.freeze
      MULTIPARAMETER_KEY = { day: 3, month: 2, year: 1, hour: 4, minute: 5, offset: 8 }.freeze

      def initialize(builder, object_name, attribute_name, legend:, caption:, hint:, omit_day:, maxlength_enabled:,
                     form_group:, date_of_birth: false, **kwargs, &block)
        super(builder, object_name, attribute_name, &block)

        @legend            = legend
        @caption           = caption
        @hint              = hint
        @date_of_birth     = date_of_birth
        @omit_day          = omit_day
        @maxlength_enabled = maxlength_enabled
        @form_group        = form_group
        @html_attributes   = kwargs
      end

      def html
        Containers::FormGroup.new(*bound, **@form_group, **@html_attributes).html do
          Containers::Fieldset.new(*bound, **fieldset_options).html do
            safe_join([supplemental_content, hint_element, error_element, date])
          end
        end
      end

      private

      def fieldset_options
        { legend: @legend, caption: @caption, described_by: [error_id, hint_id, supplemental_id],
          data:   { controller: "datetimes" } }
      end

      def date
        tag.div(class: %(#{brand}-date-input)) do
          safe_join([day, month, year, hour, minute, meridian, offset])
        end
      end

      def omit_day?
        @omit_day
      end

      def maxlength_enabled?
        @maxlength_enabled
      end

      def day
        if omit_day?
          return tag.input(
            id:    id(:day, false),
            name:  name(:day),
            type:  "hidden",
            value: value(:day) || 1,
          )
        end

        date_part(:day, width: 2, link_errors: true)
      end

      def month
        date_part(:month, width: 2, link_errors: omit_day?)
      end

      def year
        date_part(:year, width: 4)
      end

      def hour
        tag.div(class: %(#{brand}-date-input__item)) do
          tag.div(class: %(#{brand}-form-group)) do
            safe_join([hidden_hour, label(:hour, false), visible_hour])
          end
        end
      end

      def hidden_hour
        tag.input(name:  name(:hour),
                  type:  :hidden,
                  value: attribute&.strftime("%k"),
                  data:  {
                    datetimes_target: "hiddenHour",
                  },
                  id:    "claim_damage_occurred_at_hour_hidden")
      end

      def visible_hour
        tag.input(name:      "#{@attribute_name}_hours_visible",
                  value:     attribute&.strftime("%I"),
                  data:      {
                    datetimes_target: "hour",
                    action:           <<~ACTIONS,
                      input->datetimes#validateHour blur->datetimes#blurValidateHour
                      input->datetimes#tabHour blur->datetimes#updateHiddenHourAmPm
                    ACTIONS
                    pattern:          "^([0]|[0]{0,1}[1-9]|[1][0-2])$", # allow single initial 0 while typing
                    blur_pattern:     "^([0]{0,1}[1-9]|[1][0-2])$", # but require 2 digits on blur
                  },
                  id:        "#{@attribute_name}_hour",
                  class:     classes(2),
                  maxlength: "2",
                  width:     2,
                  inputmode: "numeric",
                  pattern:   "^([0]{0,1}[1-9]|[1][0-2])$")
      end

      def minute
        tag.div(class: %(#{brand}-date-input__item)) do
          tag.div(class: %(#{brand}-form-group)) do
            safe_join([label(:minute, false), minute_input])
          end
        end
      end

      def minute_input
        tag.input(name:      name(:minute),
                  value:     attribute&.strftime("%M"),
                  data:      {
                    datetimes_target: "minute",
                    action:           "input->datetimes#validateMinute blur->datetimes#blurValidateMinute",
                    pattern:          "^([0-9]|[0][0-9]|[1-5][0-9])$", # allow single numeric input while typing
                    blur_pattern:     "^([0-5][0-9])$", # but require 2 digits on blur
                  },
                  id:        "#{@attribute_name}_minute",
                  class:     classes(2),
                  maxlength: "2",
                  width:     2,
                  inputmode: "numeric",
                  pattern:   "^([0-5][0-9])$")
      end

      def offset
        tag.input(
          id:    id(:offset, false),
          name:  name(:offset),
          value: Time.now.utc_offset,
          type:  :hidden,
        )
      end

      def meridian
        tag.div(class: %(#{brand}-date-input__item #{brand}-date-input__meridian)) do
          tag.div(class: %(#{brand}-form-group)) do
            @builder.govuk_radio_buttons_fieldset "", legend: { text: false }, inline: true, small: true do
              @builder.govuk_radio_button("#{@attribute_name}_meridian",
                                          "am",
                                          label:   { text: "am" },
                                          checked: attribute.nil? || attribute.strftime("%P") == "am",
                                          data:    {
                                            action: "click->datetimes#updateHiddenHourAmPm",
                                          }) +
                @builder.govuk_radio_button("#{@attribute_name}_meridian",
                                            "pm",
                                            label:   { text: "pm" },
                                            checked: attribute&.strftime("%P") == "pm",
                                            data:    {
                                              datetimes_target: "pm",
                                              action:           "click->datetimes#updateHiddenHourAmPm",
                                            })
            end
          end
        end
      end

      def attribute
        @builder.object.try(@attribute_name)
      end

      def date_part(segment, width:, link_errors: false)
        tag.div(class: %(#{brand}-date-input__item)) do
          tag.div(class: %(#{brand}-form-group)) do
            safe_join([label(segment, link_errors), input(segment, link_errors, width, value(segment))])
          end
        end
      end

      def value(segment)
        attribute = @builder.object.try(@attribute_name)

        return unless attribute

        if attribute.respond_to?(segment)
          attribute.send(segment)
        elsif attribute.respond_to?(:fetch)
          attribute.fetch(MULTIPARAMETER_KEY[segment]) do
            warn("No key '#{segment}' found in MULTIPARAMETER_KEY hash. Expected to find #{MULTIPARAMETER_KEY.values}")

            nil
          end
        else
          fail(ArgumentError,
               "invalid Date-like object: must be a Date, Time, DateTime or Hash in MULTIPARAMETER_KEY format")
        end
      end

      def label(segment, link_errors)
        tag.label(
          segment.capitalize,
          class: label_classes,
          for:   id(segment, link_errors),
        )
      end

      def input(segment, link_errors, width, value)
        tag.input(
          id:           id(segment, link_errors),
          class:        classes(width),
          name:         name(segment),
          type:         "text",
          inputmode:    "numeric",
          value:,
          autocomplete: date_of_birth_autocomplete_value(segment),
          maxlength:    (width if maxlength_enabled?),
        )
      end

      def classes(width)
        build_classes(
          %(input),
          %(date-input__input),
          %(input--width-#{width}),
          %(input--error) => has_errors?,
        ).prefix(brand)
      end

      # if the field has errors we want the govuk_error_summary to
      # be able to link to the day field. Otherwise, generate IDs
      # in the normal fashion
      def id(segment, link_errors)
        if has_errors? && link_errors
          field_id(link_errors:)
        else
          [@object_name, @attribute_name, SEGMENTS.fetch(segment)].join("_")
        end
      end

      def name(segment)
        format(
          "%<object_name>s[%<input_name>s(%<segment>s)]",
          object_name: @object_name,
          input_name:  @attribute_name,
          segment:     SEGMENTS.fetch(segment),
        )
      end

      def date_of_birth_autocomplete_value(segment)
        return unless @date_of_birth

        { day: "bday-day", month: "bday-month", year: "bday-year" }.fetch(segment)
      end

      def label_classes
        build_classes(%(label), %(date-input__label)).prefix(brand)
      end
    end

    def date
      tag.div(class: %(#{brand}-date-input)) do
        safe_join([day, month, year, hour, minute])
      end
    end
  end
end

module GOVUKDesignSystemFormBuilder
  module Builder
    delegate :config, to: GOVUKDesignSystemFormBuilder

    # Generates 5 inputs for the +day+, +month+, +year+, +hour+, +minute+ components of a date
    #
    # @note When using this input be aware that Rails's multiparam time and date handling falls foul
    #   of {https://bugs.ruby-lang.org/issues/5988 this} bug, so incorrect dates like +2019-09-31+ will
    #   be 'rounded' up to +2019-10-01+.
    # @note When using this input values will be retrieved
    # from the attribute if it is a Date object or a multiparam date hash
    # @param attribute_name [Symbol] The name of the attribute
    # @param hint [Hash,Proc] The content of the hint. No hint will be added if 'text' is left +nil+. When a +Proc+ is
    #   supplied the hint will be wrapped in a +div+ instead of a +span+
    # @option hint text [String] the hint text
    # @option hint kwargs [Hash] additional arguments are applied as attributes to the hint
    # @param legend [NilClass,Hash,Proc] options for configuring the legend. Legend will be omitted if +nil+.
    # @option legend text [String] the fieldset legend's text content
    # @option legend size [String] the size of the fieldset legend font, can be +xl+, +l+, +m+ or +s+
    # @option legend tag [Symbol,String] the tag used for the fieldset's header, defaults to +h1+.
    # @option legend hidden [Boolean] control the visibility of the legend.
    # Hidden legends will still be read by screenreaders
    # @option legend kwargs [Hash] additional arguments are applied as attributes on the +legend+ element
    # @param caption [Hash] configures or sets the caption content which is inserted above the legend
    # @option caption text [String] the caption text
    # @option caption size [String] the size of the caption, can be +xl+, +l+ or +m+. Defaults to +m+
    # @option caption kwargs [Hash] additional arguments are applied as attributes on the caption +span+ element
    # @param omit_day [Boolean] do not render a day input, only capture month and year
    # @param maxlength_enabled [Boolean] adds maxlength attribute
    # to day, month and year inputs (2, 2, and 4, respectively)
    # @param form_group [Hash] configures the form group
    # @option form_group kwargs [Hash] additional attributes added to the form group
    # @option kwargs [Hash] kwargs additional arguments are applied as attributes to the +input+ element
    # @param block [Block] arbitrary HTML that will be rendered between the hint and the input group
    # @param date_of_birth [Boolean]
    # if +true+ {https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/autocomplete#Values
    # birth date auto completion attributes}
    #   will be added to the inputs
    # @return [ActiveSupport::SafeBuffer] HTML output
    #
    # @see https://github.com/alphagov/govuk-frontend/issues/1449 GOV.UK
    # date input element attributes, using text instead of number
    # @see https://design-system.service.gov.uk/styles/typography/#headings-with-captions Headings with captions
    #
    # @example A regular date input with a legend, hint and injected content
    #   = f.govuk_date_time_field :starts_on,
    #     legend: { 'When does your event start?' },
    #     hint: { text: 'Leave this field blank if you don't know exactly' } do
    #
    #       p.govuk-inset-text
    #         | If you don't fill this in you won't be eligable for a refund
    #
    # @example A date input with legend supplied as a proc
    #  = f.govuk_date_time_field :finishes_on,
    #    legend: -> { tag.h3('Which category do you belong to?') }
    def govuk_date_time_field(attribute_name, hint: {}, label: {}, caption: {}, form_group: {}, omit_day: false,
                              maxlength_enabled: false, **kwargs, &block)
      Elements::DateTime.new(self,
                             object_name,
                             attribute_name,
                             hint:,
                             legend:            label,
                             caption:,
                             omit_day:,
                             maxlength_enabled:,
                             form_group:,
                             **kwargs,
                             &block).html
    end
  end
end
