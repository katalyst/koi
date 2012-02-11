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

  def divs(*cs, &b)
    cs.empty? ? capture(&b) : with(cs.shift) { |c| content_tag :div, divs(*cs, &b), class: c }
  end

end
