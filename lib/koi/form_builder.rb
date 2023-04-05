# frozen_string_literal: true

module Koi
  class FormBuilder < ActionView::Helpers::FormBuilder
    delegate_missing_to :@template

    include GOVUKDesignSystemFormBuilder::Builder

    # Generates a submit button for saving admin resources.
    def admin_save(text = "Save", name: :commit, value: :save, class: "button button--primary", **kwargs)
      button(text, name:, value:, class:, **kwargs)
    end

    # Generates a delete link formatted as a button that will perform a turbo
    # delete with a confirmation.
    def admin_delete(text = "Delete", url: nil, confirm: "Are you sure?", data: {}, **kwargs)
      return unless object.persisted?

      link_to(text, url || url_for(action: :destroy),
              class: "button button--secondary",
              data:  data.reverse_merge(turbo_method: :delete, turbo_confirm: confirm),
              **kwargs)
    end

    # Generates an archive link formatted as a button that will perform a turbo
    # delete with a confirmation.
    def admin_archive(text = "Archive", **kwargs)
      admin_delete(text, **kwargs)
    end

    # Generates a discard changes link formatted as a text button that navigates
    # the user back to the previous page.
    def admin_discard(text = "Discard", url: :back, **kwargs)
      link_to(text, url, class: "button button--text", **kwargs)
    end

    # @api internal
    # @see GOVUKDesignSystemFormBuilder::Builder#govuk_document_field
    def govuk_document_field(attribute_name, hint: {}, **kwargs, &block)
      max_size = hint[:max_size] || App::PERMITTED_IMAGE_SIZE
      super(attribute_name, hint:, **kwargs) do
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
      super(attribute_name, hint:, **kwargs) do
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
      super(attribute_name, data:, **kwargs, &block)
    end
  end
end
