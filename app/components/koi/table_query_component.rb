# frozen_string_literal: true

module Koi
  class TableQueryComponent < Katalyst::Tables::QueryComponent
    def call
      content_tag(:"koi-toolbar") do
        render_parent
      end
    end

    private

    using Katalyst::HtmlAttributes::HasHtmlAttributes

    def default_html_attributes
      super.merge_html(data: { action: %w[
                         shortcut:search@document->tables--query#focus
                       ] })
    end
  end
end
