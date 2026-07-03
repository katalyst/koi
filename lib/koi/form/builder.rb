# frozen_string_literal: true

module Koi
  module Form
    module Builder
      extend ActiveSupport::Concern

      # Generates a submit button for saving admin resources.
      # @deprecated will be removed in Koi 6.0
      def admin_save(text = "Save", name: :commit, value: :save, class: "button", **)
        button(text, name:, value:, class:, **)
      end

      # Generates a delete link formatted as a button that will perform a turbo
      # delete with a confirmation.
      # @deprecated will be removed in Koi 6.0
      def admin_delete(text = "Delete", url: nil, confirm: "Are you sure?", data: {}, **)
        return unless object.persisted?

        link_to(text, url || url_for(action: :destroy),
                class: "button",
                data:  data.reverse_merge(turbo_method: :delete, turbo_confirm: confirm, ghost_button: ""),
                **)
      end

      # Generates an archive link formatted as a button that will perform a turbo
      # delete with a confirmation.
      # @deprecated will be removed in Koi 6.0
      def admin_archive(text = "Archive", **)
        admin_delete(text, **)
      end

      # Generates a discard changes link formatted as a text button that navigates
      # the user back to the previous page.
      # @deprecated will be removed in Koi 6.0
      def admin_discard(text = "Discard", url: :back, **)
        link_to(text, url, class: "button", data: { text_button: "" }, **)
      end

      # @api internal
      # @see GOVUKDesignSystemFormBuilder::Builder#govuk_document_field
      def govuk_document_field(attribute_name, hint: {}, **, &)
        if hint.is_a?(Hash)
          max_size      = hint.fetch(:max_size, Koi.config.document_size_limit)
          hint[:text] ||= t("helpers.hint.default.document", max_size: @template.number_to_human_size(max_size))
        end

        super
      end

      # @api internal
      # @see GOVUKDesignSystemFormBuilder::Builder#govuk_image_field
      def govuk_image_field(attribute_name, hint: {}, **, &)
        if hint.is_a?(Hash)
          max_size      = hint.fetch(:max_size, Koi.config.image_size_limit)
          hint[:text] ||= t("helpers.hint.default.document", max_size: @template.number_to_human_size(max_size))
        end

        super
      end

      using Katalyst::HtmlAttributes::HasHtmlAttributes

      # Use Koi's admin direct uploads URL.
      #
      # @api internal
      # @see Lexxy::FormBuilder#lexxy_rich_textarea
      def lexxy_rich_textarea(attribute_name, **attributes, &)
        attributes = {
          class: "lexxy-content",
          data:  { direct_upload_url: @template.main_app.admin_direct_uploads_url },
        }.merge_html(**attributes)

        super
      end

      # Use Koi's admin direct uploads URL.
      #
      # @api internal
      # @see Koi::ActionText::FormBuilder#trix_rich_textarea
      def trix_rich_textarea(attribute_name, **attributes, &)
        attributes = {
          class: "trix-content",
          data:  { direct_upload_url: @template.main_app.admin_direct_uploads_url },
        }.merge_html(**attributes)

        super
      end
    end
  end
end
