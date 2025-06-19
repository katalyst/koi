# frozen_string_literal: true

module Koi
  module ModalHelper
    def koi_modal_tag(frame_id = "modal", frame: {}, dialog: {}, **attributes, &block)
      if block
        turbo_frame_tag(frame_id, **_koi_modal_frame_attributes(frame)) do
          tag.dialog(**_koi_modal_dialog_attributes(dialog)) do
            tag.article(**_koi_modal_article_attributes(attributes), &block)
          end
        end
      else
        turbo_frame_tag(frame_id, **_koi_modal_frame_attributes(frame))
      end
    end

    def koi_modal_header(title:, **)
      tag.header(class: "repel", data: "nowrap") do
        concat(tag.h2(title))
        concat(tag.button(
          class: "button",
          data:  {
            action:         "koi--modal#dismiss",
            button_padding: "tight",
            "text-button":  "",
          },
        ) do
          tag.icon("&nbsp;".html_safe, aria: { hidden: true }, class: "icon", data: { icon: "close" }) +
            tag.span("Close", class: "visually-hidden")
        end)
      end
    end

    def koi_modal_footer(submit = "Save", discard = "Discard", form_id:, reverse: true)
      tag.footer(class: "actions", data: { reverse: ("" if reverse) }) do
        concat(tag.button(submit, form: form_id, class: "button", data: { close_dialog: "" }))
        if discard.present?
          concat(tag.button(discard, form: form_id, formmethod: "dialog", class: "button", data: { ghost_button: "" }))
        end
      end
    end

    private

    using Katalyst::HtmlAttributes::HasHtmlAttributes

    def _koi_modal_frame_attributes(attributes)
      {
        data: { controller: "koi--modal" },
      }.merge_html(attributes)
    end

    def _koi_modal_dialog_attributes(attributes)
      {
        class: "modal",
        data:  {
          koi__modal_target: "dialog",
          action:            %w[
            click->koi--modal#click
            close->koi--modal#dismiss
          ],
        },
      }.merge_html(attributes)
    end

    def _koi_modal_article_attributes(attributes)
      {
        class: "flow",
      }.merge_html(attributes)
    end
  end
end
