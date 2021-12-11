class ActiveItemsRenderer < SimpleNavigation::Renderer::Breadcrumbs
  def render(item_container)
    collect(item_container)
  end

  protected

  def collect(item_container)
    item_container.items.inject([]) do |list, item|
      if item.selected?
        list << NavItem.find_by_id(item.key.gsub("key_", "")).setting_prefix if item.selected?
        if include_sub_navigation?(item)
          list.concat collect(item.sub_navigation)
        end
      end
      list
    end
  end
end
