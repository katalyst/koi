# frozen_string_literal: true

module Koi
  module ActionText
    module TagHelper
      using Katalyst::HtmlAttributes::HasHtmlAttributes

      def koi_trix_toolbar_tag(**)
        Tags::TrixToolbar.new(**).render
      end

      def koi_rich_textarea_tag(name, value = nil, options = {}, &)
        case Koi.action_text_editor
        when :lexxy
          lexxy_rich_textarea_tag(name, value, options, &)
        when :trix
          options = options.symbolize_keys
          trix_id = options[:id]

          toolbar = koi_trix_toolbar_tag(id: "trix-toolbar-#{trix_id}")
          editor  = trix_rich_textarea_tag(name, value, {
            data:    { turbo_permanent: "" },
            toolbar: "trix-toolbar-#{trix_id}",
            trix_id:,
          }.merge_html(options), &)

          toolbar + editor
        end
      end
    end

    module FormHelper
      def koi_rich_textarea(...)
        case Koi.action_text_editor
        when :lexxy
          lexxy_rich_textarea(...)
        when :trix
          trix_rich_textarea(...)
        end
      end
    end

    module FormBuilder
      def koi_rich_textarea(...)
        case Koi.action_text_editor
        when :lexxy
          lexxy_rich_textarea(...)
        when :trix
          trix_rich_textarea(...)
        end
      end
    end

    module ActionTextTag
      def koi_render(...)
        case Koi.action_text_editor
        when :lexxy
          lexxy_render(...)
        when :trix
          trix_render(...)
        end
      end
    end

    # Add aliases for trix default methods so that Koi can swap between trix and lexxy based on feature flags.
    def capture_action_text_defaults
      ::ActionText::TagHelper.module_eval do
        alias_method :trix_rich_textarea_tag, :rich_textarea_tag
        alias_method :trix_rich_text_area_tag, :rich_text_area_tag
      end

      ::ActionView::Helpers::FormHelper.module_eval do
        alias_method :trix_rich_textarea, :rich_textarea
        alias_method :trix_rich_text_area, :rich_text_area
      end

      ::ActionView::Helpers::FormBuilder.module_eval do
        alias_method :trix_rich_textarea, :rich_textarea
        alias_method :trix_rich_text_area, :rich_textarea
      end

      ::ActionView::Helpers::Tags::ActionText.module_eval do
        alias_method :trix_render, :render
      end
    end
    module_function :capture_action_text_defaults

    # Add shims for rich_textarea and friends.
    # This is intended as a migration path and will be removed when Rails 8.2 is released.
    def override_action_text_defaults
      ::ActionText::TagHelper.module_eval do
        alias_method :rich_textarea_tag, :koi_rich_textarea_tag
        alias_method :rich_text_area_tag, :koi_rich_textarea_tag
      end

      ::ActionView::Helpers::FormHelper.module_eval do
        alias_method :rich_textarea, :koi_rich_textarea
        alias_method :rich_text_area, :koi_rich_textarea
      end

      ::ActionView::Helpers::FormBuilder.module_eval do
        alias_method :rich_textarea, :koi_rich_textarea
        alias_method :rich_text_area, :koi_rich_textarea
      end

      ::ActionView::Helpers::Tags::ActionText.module_eval do
        alias_method :render, :koi_render
      end
    end
    module_function :override_action_text_defaults
  end
end
