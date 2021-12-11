class SfMenuRenderer < SimpleNavigation::Renderer::List
  def render(item_container)
    item_container.dom_class = options.delete(:dom_class) if options.has_key?(:dom_class)
    item_container.dom_id = options.delete(:dom_id) if options.has_key?(:dom_id)
    item_container.items.each { |i| p i.html_options = { link: options[:link] } } if options.has_key?(:link)
    super
  end
end
