require 'ostruct'

module Koi::NavigationHelper

  def cascaded_setting(key)
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

    images.try(:map)

    image_tags = ""
    images.try(:each) do |image|
      image_tags << image_tag(image.url(size: "100x"))
    end
    image_tags
  end

  def highlighted_nav root = nil, &filter
    navs(root, &filter).sort_by(&:negative_highlight).first
  end

  def navs root = nil, &filter
    nav(root, &filter).self_and_descendants
  end

  def nav nav_item = nil, &filter
    nav_for_id NavItem.for(nav_item).id, &filter
  end

  def nav_for_id id, &filter
    navs_by_id(&filter)[id]
  end

  def navs_by_id &filter
    @navs_by_id ||= navs_by_id!(&filter).each do |id, nav|
      if nav.parent_id
        nav.parent = navs_by_id![nav.parent_id]
        nav.parent.children << nav
      end
    end
  end

  def navs_by_id! &filter
    @navs_by_id ||= Hash[ nav_items.map { |nav_item| [nav_item.id, Navigator.new(self, nav_hash_for_id(nav_item.id), &filter) ] }]
  end

  def nav_hash_for_id id
    nav_hashes_by_id[id]
  end

  def nav_hashes_by_id
    @nav_hashes_by_id ||= Hash[ nav_items.map { |nav_item| [nav_item.id, nav_item.to_hashish] }]
  end

  def nav_items
    @nav_items ||= NavItem.order :lft
  end

  class Navigator < OpenStruct

    def initialize *etc, &filter
      super etc.extract_options! while Hash === etc.last
      self.filter   ||= filter || -> { true }
      self.template ||= etc.shift
      self.children ||= []
      self.highlight!
    end

    def request
      template.request
    end

    def children
      return super
      super.select &:is_navigable? if super
    end

    def ancestors
      @ancestors ||= (parent ? parent.ancestors + [parent] : []).drop_while(&:isnt_navigable?)
    end

    def self_and_ancestors
      @self_and_ancestors ||= ancestors + [self]
    end

    def self_and_descendants
      @self_and_descendants ||= [self] + descendants
    end

    def descendants
      @descendants ||= self.children.map(&:descendants).flatten
    end

    def highlight!
      if @highlight.nil? 
        @highlight  = 00000
        @highlight += 10000 if instance_exec url, &highlights_on if highlights_on
        @highlight += 00100 if url == request.fullpath
        @highlight += 00001 if url == request.path
        @highlight *= depth
      end
    end

    def highlight
      @highlight
    end

    def path_highlight
      @path_highlight ||= highlight || children.max(&:path_highlight)
    end

    def negative_highlight
      -@highlight
    end

    def is_highlighted?
      @is_highlighted ||= highlight > 0
    end

    def is_path_highlighted?
      @is_path_highlighted ||= path_highlight > 0
    end

    def is_mobile?
      @is_mobile
    end

    def is_path_mobile?
      @is_path_mobile = is_mobile? || parent && parent.is_path_mobile? if @is_path_mobile.nil?
      @is_path_mobile
    end

    def is_desktop?
      ! is_mobile?
    end

    def is_path_desktop?
      ! is_path_desktop?
    end

    def is_hidden?
      @is_hidden
    end

    def is_visible?
      ! is_hidden?
    end

    def is_navigable?
      is_visible? && instance_exec(&filter)
    end

    def isnt_navigable?
      ! is_navigable?
    end

    def level
      @level ||= parent ? parent.level + 1 : 0
    end

    def depth
      @depth ||= -level
    end

    def link_to opt = {}
      keys = opt.keys.map &:to_s
      keys.grep(/!$/).each do |key|
        o = opt.delete key
        opt.merge! o if send key.gsub /!$/, "?"
      end
      keys.grep(/\?$/).each do |key|
        o = opt.delete key
        opt.merge_html! o if send key
      end
      template.link_to title, url, opt
    end

  end
end

