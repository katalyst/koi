module Koi::HtmlHelper

  # Description:
  #
  #   Adds classes to the body tag.
  #
  # Usage:
  #
  #   <% page_type 'home' %>
  #
  def page_type(*types)
    @page_types ||= []
    return @page_types.join(" ") if types.blank?
    @page_types += types.flatten
    return @page_types
  end

  def divs *cs, &b
    cs.empty? ? capture(&b) : with(cs.shift) { |c| content_tag :div, divs(*cs, &b), class: c }
  end

  def rich_text *sig, &blk
    opt = sig.extract_options!.merge_html! class: "koi-rich-text"
    tag = Symbol === sig.first ? sig.shift : :div
    txt = String === sig.first ? sig.shift : capture(&blk)
    txt = simple_format?(txt)  ? simple_format(txt) : sterilize(txt)
    content_tag tag, txt, opt
  end

  def simple_format? txt
    txt == strip_tags(txt)
  end

  def sterilize? txt
    ! simple_format? txt
  end

  def raw? txt
    ! simple_format? txt
  end

end
