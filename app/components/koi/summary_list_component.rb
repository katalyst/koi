# frozen_string_literal: true

module Koi
  class SummaryListComponent < ViewComponent::Base
    include Katalyst::HtmlAttributes

    renders_many :definitions, types: {
      boolean:    SummaryList::BooleanComponent,
      date:       SummaryList::DateComponent,
      datetime:   SummaryList::DatetimeComponent,
      number:     SummaryList::NumberComponent,
      rich_text:  SummaryList::RichTextComponent,
      text:       SummaryList::TextComponent,
      attachment: SummaryList::AttachmentComponent,

      # @deprecated legacy interface
      item:       SummaryList::ItemComponent,
    }

    def initialize(model: nil, skip_blank: true, **)
      super(**)

      @model      = model
      @skip_blank = skip_blank
    end

    def boolean(attribute, label: nil, &)
      with_definition_boolean(@model, attribute, label:, &)
    end

    def date(attribute, label: nil, format: :admin, skip_blank: @skip_blank, &)
      with_definition_date(@model, attribute, label:, format:, skip_blank:, &)
    end

    def datetime(attribute, label: nil, format: :admin, skip_blank: @skip_blank, &)
      with_definition_datetime(@model, attribute, label:, format:, skip_blank:, &)
    end

    def rich_text(attribute, label: nil, skip_blank: @skip_blank, &)
      with_definition_rich_text(@model, attribute, label:, skip_blank:, &)
    end

    def number(attribute, label: nil, skip_blank: @skip_blank, &)
      with_definition_number(@model, attribute, label:, skip_blank:, &)
    end

    def text(attribute, label: nil, skip_blank: @skip_blank, &)
      with_definition_text(@model, attribute, label:, skip_blank:, &)
    end

    def attachment(attribute, label: nil, skip_blank: @skip_blank, variant: :thumb, &)
      with_definition_attachment(@model, attribute, label:, skip_blank:, variant:, &)
    end

    # @deprecated legacy interface
    def item(model, attribute, label: nil, skip_blank: @skip_blank, &)
      with_definition_item(model, attribute, label:, skip_blank:, &)
    end

    # @deprecated legacy interface
    def items_with(model:, attributes:, **options)
      attributes.each do |attribute|
        item(model, attribute, **options)
      end
    end

    def inspect
      "#<#{self.class.name}>"
    end

    def default_html_attributes
      { class: "summary-list" }
    end
  end
end
