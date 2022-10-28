# frozen_string_literal: true

module Koi
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate :content_tag, :tag, :safe_join, :link_to, :capture, :concat, :t, to: :@template

    include GOVUKDesignSystemFormBuilder::Builder

    # @api internal
    # @see GOVUKDesignSystemFormBuilder::Builder#govuk_document_field
    def govuk_document_field(attribute_name, hint: {}, **kwargs, &block)
      max_size = hint[:max_size] || App::PERMITTED_IMAGE_SIZE
      super(attribute_name, hint: hint, **kwargs) do
        if block
          concat(yield)
        else
          concat(t("helpers.hint.default.document", max_size: @template.number_to_human_size(max_size)))
        end
      end
    end

    # @api internal
    # @see GOVUKDesignSystemFormBuilder::Builder#govuk_image_field
    def govuk_image_field(attribute_name, hint: {}, **kwargs, &block)
      max_size = hint[:max_size] || App::PERMITTED_IMAGE_SIZE
      super(attribute_name, hint: hint, **kwargs) do
        if block
          concat(yield)
        else
          concat(t("helpers.hint.default.image", max_size: @template.number_to_human_size(max_size)))
        end
      end
    end

    # Use content editor trix setup by default.
    #
    # @api internal
    # @see GOVUKDesignSystemFormBuilder::Builder#govuk_rich_text_area
    def govuk_rich_text_area(attribute_name, data: {}, **kwargs, &block)
      data = data.reverse_merge(
        direct_upload_url: @template.katalyst_content.direct_uploads_url,
        controller:        "content--editor--trix",
        action:            "trix-initialize->content--editor--trix#trixInitialize",
      )
      super(attribute_name, data: data, **kwargs, &block)
    end
  end
end