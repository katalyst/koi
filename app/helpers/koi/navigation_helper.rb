module Koi::NavigationHelper
  def active_item_cascade
    NavItem.find_by_id(active_navigation_item_key.gsub("key_", "")).try(:self_and_ancestors)
  end
end
