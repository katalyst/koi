# frozen_string_literal: true

module Koi
  module Form
    module Content
      extend ActiveSupport::Concern

      def content_heading_fieldset
        govuk_fieldset(legend: { text: "Heading", size: "m" }) do
          concat(content_heading_field(label: nil))
          concat(content_heading_style_field)
        end
      end

      def content_heading_field(args = {})
        govuk_text_field(:heading,
                         **{ label: { text: "Heading", size: "s" } }.deep_merge(args))
      end

      def content_heading_style_field(args = {})
        govuk_collection_radio_buttons(:heading_style,
                                       Katalyst::Content.config.heading_styles,
                                       :itself,
                                       :itself,
                                       **{ small: true, legend: { text: "Style", size: "s" } }.deep_merge(args))
      end

      def content_url_field(args = {})
        govuk_text_field(:url,
                         **{ label: { text: "URL", size: "s" } }.deep_merge(args))
      end

      def content_http_method_field(methods, args = {})
        govuk_select(:http_method, methods,
                     **{ label: { text: "HTTP method", size: "s" } }.deep_merge(args))
      end

      def content_target_field(targets, args = {})
        govuk_select(:target, targets,
                     **{ label: { text: "HTTP target", size: "s" } }.deep_merge(args))
      end

      def content_background_field(args = {})
        govuk_select(:background, Katalyst::Content.config.backgrounds,
                     **{ label: { size: "s" } }.deep_merge(args))
      end

      def content_visible_field(args = {})
        govuk_check_box_field(:visible,
                              **{ label: { text: "Visible? ", size: "s" }, small: true }.deep_merge(args))
      end
    end
  end
end
