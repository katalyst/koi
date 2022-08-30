# frozen_string_literal: true

module Koi
  module NavigationHelper
    def koi_render_navigation(cache_key, nav_items_fetch_key = nil, options = {})
      if Koi::Caching.enabled
        cache_render_navigation(cache_key, nav_items_fetch_key, options)
      else
        get_render_navigation(nav_items_fetch_key, options)
      end
    end

    def cache_render_navigation(cache_key, nav_items_fetch_key = nil, options = {})
      request_path = request.path.parameterize if request.path
      cache_key    = "#{request_path}_#{cache_key}"

      Rails.cache.fetch(prefix_cache_key(cache_key), expires_in: cache_expiry) do
        get_render_navigation(nav_items_fetch_key, options)
      end
    end

    def get_render_navigation(nav_items_fetch_key = nil, options = {})
      options[:items] = get_nav_items(nav_items_fetch_key) if nav_items_fetch_key
      render_navigation options
    end

    def get_nav_items(key)
      if Koi::Caching.enabled
        Rails.cache.fetch(prefix_cache_key(key), expires_in: cache_expiry) do
          NavItem.navigation(key)
        end
      else
        NavItem.navigation(key)
      end
    end

    def cascaded_setting(key)
      active_item_prefixes = render_navigation renderer: :active_items
      active_item_prefixes << settings_prefix
      active_item_prefixes.uniq.compact!

      setting = nil

      if is_settable?
        active_item_prefixes.reverse.each do |prefix|
          break if setting.present?

          value   = Setting.find_by(prefix: prefix, key: key).try(:value)
          setting = value if value.present?
        end
      end

      setting
    end

    def cascaded_banners
      images = cascaded_setting(:banners)
      images = [] unless images.is_a?(Enumerable)
      images.sum { |image| image_tag image.url(size: "100x") }
    end

    def breadcrumbs
      @breadcrumbs ||= breadcrumb.self_and_ancestors
    end

    def breadcrumb
      @breadcrumb ||= nav.self_and_descendants.compact.min_by(&:negative_highlight)
    end

    def navigation_item(menu, title, url, index, depth)
      link = Katalyst::Navigation::Item.new
      link.menu = menu
      link.title = title
      link.url = url
      link.index = index
      link.depth = depth
      link
    end

    def build_tree(key, value, depth, menu, item_container)
      has_child_nodes = value.is_a? Hash
      item = navigation_item(menu, key, (has_child_nodes ? "#" : value), @index, depth)
      item_container << {id: @index, depth: item.depth, index: @index}
      @index = @index + 1
      if has_child_nodes
        depth = depth + 1
        value.each do |child_key, child_value|
          build_tree(child_key, child_value, depth, menu, item_container)
        end
      end
    end

    def build_navigation_menu(items)
      item_attributes = []
      @index = 0
      menu = Katalyst::Navigation::Menu.new
      items.each do |key, value|
        build_tree(key, value, 0, menu, item_attributes)
      end
      menu.items_attributes = item_attributes
      menu.published_version = menu.draft_version.dup
      menu
    end

    # @param(menu_items: Koi::Menu.items)
    # @return Structured HTML containing top level + nested navigation links
    def render_navigation_menu(menu_items, ul_options: {}, child_ul_options: {}, li_options: {})
      menu = build_navigation_menu(menu_items)
      return unless menu&.published_version&.present?

      cache menu.published_version do
        content = with_output_buffer do
          menu.published_version.tree.each do |link|
            output_buffer << render_navigation_link(link, child_ul_options:, li_options:)
          end
        end
        output_buffer << content_tag(:ul, content, ul_options)
      end
    end

    # Renders an `a` tag for the given Katalyst::Navigation::Link.
    # Renders a `ul` containing the children of the Katalyst::Navigation::Link.
    def render_navigation_link(link, child_ul_options: {}, li_options: {})
      content = with_output_buffer do
        output_buffer << link_to(link.title, link.url)
        output_buffer << render_nested_navigation(link, child_ul_options:, li_options:) if link.children.any?
      end
      content_tag :li, content, li_options
    end

    def render_nested_navigation(link, child_ul_options: {}, li_options: {})
      content = with_output_buffer do
        link.children.each do |child|
          output_buffer << render_navigation_link(child, child_ul_options:, li_options:)
        end
      end
      content_tag :ul, content, child_ul_options
    end

    def new_items_for_navigation(menu)
      [Katalyst::Navigation::Link.new(menu: menu)]
    end

    private

    def prefix_cache_key(suffix)
      "#{Rails.application.class.module_parent}_#{suffix}"
    end

    def cache_expiry
      Koi::Caching.expires_in
    end
  end
end
