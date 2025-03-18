# frozen_string_literal: true

module Koi
  module Form
    module Builder
      extend ActiveSupport::Concern

      included do
        delegate_missing_to :@template
      end

      # Generates a submit button for saving admin resources.
      def admin_save(text = "Save", name: :commit, value: :save, class: "button", **)
        button(text, name:, value:, class:, **)
      end

      # Generates a delete link formatted as a button that will perform a turbo
      # delete with a confirmation.
      def admin_delete(text = "Delete", url: nil, confirm: "Are you sure?", data: {}, **)
        return unless object.persisted?

        link_to(text, url || url_for(action: :destroy),
                class: "button button--secondary",
                data:  data.reverse_merge(turbo_method: :delete, turbo_confirm: confirm),
                **)
      end

      # Generates an archive link formatted as a button that will perform a turbo
      # delete with a confirmation.
      def admin_archive(text = "Archive", **)
        admin_delete(text, **)
      end

      # Generates a discard changes link formatted as a text button that navigates
      # the user back to the previous page.
      def admin_discard(text = "Discard", url: :back, **)
        link_to(text, url, class: "button button--text", **)
      end

      # @api internal
      # @see GOVUKDesignSystemFormBuilder::Builder#govuk_document_field
      def govuk_document_field(attribute_name, hint: {}, **, &)
        if hint.is_a?(Hash)
          max_size = hint.fetch(:max_size, Koi.config.document_size_limit)
          hint[:text] ||= t("helpers.hint.default.document", max_size: @template.number_to_human_size(max_size))
        end

        super
      end

      # @api internal
      # @see GOVUKDesignSystemFormBuilder::Builder#govuk_image_field
      def govuk_image_field(attribute_name, hint: {}, **, &)
        if hint.is_a?(Hash)
          max_size = hint.fetch(:max_size, Koi.config.image_size_limit)
          hint[:text] ||= t("helpers.hint.default.document", max_size: @template.number_to_human_size(max_size))
        end

        super
      end

      # Use content editor trix setup by default.
      #
      # @api internal
      # @see GOVUKDesignSystemFormBuilder::Builder#govuk_rich_text_area
      def govuk_rich_text_area(attribute_name, data: {}, **, &)
        data = data.reverse_merge(
          direct_upload_url: @template.katalyst_content.direct_uploads_url,
          controller:        "content--editor--trix",
          action:            "trix-initialize->content--editor--trix#trixInitialize",
        )
        super
      end
    end
  end
end
