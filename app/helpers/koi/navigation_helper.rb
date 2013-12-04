module Koi::NavigationHelper

  def koi_render_navigation(cache_key, nav_items_fetch_key=nil, options={})
    if Koi::Caching.enabled
      cache_render_navigation(cache_key, nav_items_fetch_key, options)
    else
      get_render_navigation(nav_items_fetch_key, options)
    end
  end

  def cache_render_navigation(cache_key, nav_items_fetch_key=nil, options={})
    request_path = request.path.parameterize if request.path
    cache_key = "#{request_path}_#{cache_key}"

    Rails.cache.fetch(prefix_cache_key(cache_key), expires_in: cache_expiry) do
      get_render_navigation(nav_items_fetch_key, options)
    end
  end

  def get_render_navigation(nav_items_fetch_key=nil, options={})
    options.merge!(items: get_nav_items(nav_items_fetch_key)) if nav_items_fetch_key
    render_navigation options
  end

  def get_nav_items(key)
    if Koi::Caching.enabled
      Rails.cache.fetch(prefix_cache_key(key), expires_in: cache_expiry) do
        NavItem.navigation(key, binding())
      end
    else
      cached_nav_item(key)
    end
  end

  def cached_nav_item(key)
    @get_nav_items ||= {}
    @get_nav_items[key] ||= NavItem.navigation(key, binding())
  end

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

  private

    def prefix_cache_key(suffix)
      "#{Rails.application.class.parent_name}_#{suffix}"
    end

    def cache_expiry
      Koi::Caching.expires_in
    end

end
