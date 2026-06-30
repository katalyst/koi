# frozen_string_literal: true

module Koi
  module Tags
    class TrixToolbar
      include ActionView::Helpers::TagHelper
      include Katalyst::HtmlAttributes

      TRIX_BUTTON_ROW_TEMPLATE = <<~HTML.html_safe.freeze
        <div class="trix-button-row">
          <span class="trix-button-group trix-button-group--text-tools" data-trix-button-group="text-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-bold" data-trix-attribute="bold" data-trix-key="b" title="Bold" tabindex="-1">Bold</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-italic" data-trix-attribute="italic" data-trix-key="i" title="Italic" tabindex="-1">Italic</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-strike" data-trix-attribute="strike" title="Strikethrough" tabindex="-1">Strikethrough</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-link" data-trix-attribute="href" data-trix-action="link" data-trix-key="k" title="Link" tabindex="-1">Link</button>
          </span>

          <span class="trix-button-group trix-button-group--block-tools" data-trix-button-group="block-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-attribute="heading4" title="Heading" tabindex="-1">Heading</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-quote" data-trix-attribute="quote" title="Quote" tabindex="-1">Quote</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-code" data-trix-attribute="code" title="Code" tabindex="-1">Code</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-bullet-list" data-trix-attribute="bullet" title="Bullets" tabindex="-1">Bullets</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-number-list" data-trix-attribute="number" title="Numbers" tabindex="-1">Numbers</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-decrease-nesting-level" data-trix-action="decreaseNestingLevel" title="Decrease level" tabindex="-1">Decrease level</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-increase-nesting-level" data-trix-action="increaseNestingLevel" title="Increase level" tabindex="-1">Increase level</button>
          </span>

          <span class="trix-button-group trix-button-group--file-tools" data-trix-button-group="file-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-attach" data-trix-action="attachFiles" title="Attach files" tabindex="-1">Attach files</button>
          </span>

          <span class="trix-button-group-spacer"></span>

          <span class="trix-button-group trix-button-group--history-tools" data-trix-button-group="history-tools">
            <button type="button" class="trix-button trix-button--icon trix-button--icon-undo" data-trix-action="undo" data-trix-key="z" title="Undo" tabindex="-1">Undo</button>
            <button type="button" class="trix-button trix-button--icon trix-button--icon-redo" data-trix-action="redo" data-trix-key="shift+z" title="Redo" tabindex="-1">Redo</button>
          </span>
        </div>
      HTML

      TRIX_DIALOGS_TEMPLATE    = <<~HTML.html_safe.freeze
        <div class="trix-dialogs" data-trix-dialogs>
          <div class="trix-dialog trix-dialog--link" data-trix-dialog="href" data-trix-dialog-attribute="href">
            <div class="trix-dialog__link-fields">
              <input type="text" name="href" pattern="(https?|mailto:|tel:|/|#).*?" class="trix-input trix-input--dialog" placeholder="Enter a URL…" aria-label="URL" data-trix-validate-href required data-trix-input>
              <div class="trix-button-group">
                <input type="button" class="trix-button trix-button--dialog" value="Link" data-trix-method="setAttribute">
                <input type="button" class="trix-button trix-button--dialog" value="Unlink" data-trix-method="removeAttribute">
              </div>
            </div>
          </div>
        </div>
      HTML

      def render
        content_tag("trix-toolbar", TRIX_BUTTON_ROW_TEMPLATE + TRIX_DIALOGS_TEMPLATE, **html_attributes)
      end

      def default_html_attributes
        { data: { turbo_permanent: "" } }
      end
    end
  end
end
