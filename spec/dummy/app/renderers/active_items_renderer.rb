# frozen_string_literal: true

class ActiveItemsRenderer < SimpleNavigation::Renderer::Breadcrumbs
  def render(item_container)
    collect(item_container)
  end

  protected

  def collect(item_container)
    item_container.items.each_with_object([]) do |item, list|
      if item.selected?
        list << NavItem.find_by(id: item.key.gsub("key_", "")).setting_prefix if item.selected?
        list.concat collect(item.sub_navigation) if include_sub_navigation?(item)
      end
    end
  end
end
