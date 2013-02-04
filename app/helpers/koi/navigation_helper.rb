module Koi::NavigationHelper

  def cascaded_setting key
    active_item_prefixes = render_navigation renderer: :active_items
    active_item_prefixes << settings_prefix
    active_item_prefixes.uniq.compact!

    setting = nil

    if is_settable?
      active_item_prefixes.reverse.each do |prefix|
        break unless setting.blank?
        value = Setting.find_by_prefix_and_key(prefix, key).try(:value)
        setting = value unless value.blank?
      end
    end

    setting
  end

  def cascaded_banners
    images = cascaded_setting(:banners)
    images = [] unless Enumerable === images
    images.sum { |image| image_tag image.url(size: "100x") }
  end

  def breadcrumbs
    @breadcrumbs ||= breadcrumb.self_and_ancestors
  end

  def breadcrumb
    @breadcrumb ||= nav.self_and_descendants.compact.sort_by(&:negative_highlight).first
  end

  def nav nav_item = nil
    navs_by_id[ NavItem.for(nav_item).id ]
  end

  def navs_by_id
    @navs_by_id ||= navs_by_id!.each do |id, nav|
      if nav.parent_id
        nav.parent = navs_by_id![nav.parent_id]
        nav.parent.children << nav
      end
    end
  end

  def navs_by_id!
    @navs_by_id ||= Hash[ nav_items.map { |nav_item| [nav_item.id, nav_from(nav_item)] }]
  end

  def nav_items
    @nav_items ||= NavItem.order :lft
  end

  def nav_from nav_item
    Navigator.new self, nav_item.to_hashish(binding()) #, &filter
  end

end
