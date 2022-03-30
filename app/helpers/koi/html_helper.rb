# frozen_string_literal: true

module Koi
  # @deprecated
  module HtmlHelper
    # Description:
    #
    #   Adds classes to the body tag.
    #
    # Usage:
    #
    #   <% page_type 'home' %>
    #
    # @deprecated
    def page_type(*types)
      @page_types ||= []
      return @page_types.join(" ") if types.blank?

      @page_types += types.flatten
    end

    # @deprecated
    def divs(*cs, &b)
      cs.empty? ? capture(&b) : with(cs.shift) { |c| content_tag :div, divs(*cs, &b), class: c }
    end

    # @deprecated
    def rich_text(*sig, &blk)
      opt = sig.extract_options!.merge! class: "koi-rich-text"
      tag = sig.first.is_a?(Symbol) ? sig.shift : :div
      txt = blk ? capture(&blk) : sig.shift
      txt = simple_format?(txt) ? simple_format(txt) : sanitize(txt)
      content_tag tag, txt, opt
    end

    # @deprecated
    def simple_format?(txt)
      txt == strip_tags(txt)
    end

    # @deprecated
    def sanitize?(txt)
      !simple_format? txt
    end

    # @deprecated
    def raw?(txt)
      !simple_format? txt
    end
  end
end
