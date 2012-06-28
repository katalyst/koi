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
    @navs_by_id ||= Hash[ nav_items.map { |nav_item| [nav_item.id, nav_from(nav_item) ] }]
  end

  def nav_items
    @nav_items ||= NavItem.order :lft
  end

  def nav_from nav_item
    Navigator.new self, nav_item.to_hashish(binding()) #, &filter
  end

  class Navigator < OpenStruct

    def initialize *etc, &filter
      super etc.extract_options! while Hash === etc.last
      self.filter   ||= filter || -> { true }
      self.template ||= etc.shift
      self.children ||= []

      self.children = children.map do |child|
        case child
        when Navigator
          child
        when Hash
          n = Navigator.new template, child, &filter
          n.parent = self
          n
        end
      end unless children.empty?
    end

    def request
      template.request
    end

    def root
      ancestors.first
    end

    def children
      return super
      super.select &:is_navigable? if super
    end

    def self_and_children
      @self_and_children ||= [self] + children
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
      @descendants ||= children + children.map(&:descendants).flatten
    end

    def highlight
      @highlight ||= highlight!
    end

    def highlight!
      @highlight  = 00000
      @highlight += 10000 if instance_exec url, &highlights_on if highlights_on
      @highlight += 00100 if url == request.fullpath
      @highlight += 00001 if url == request.path
      @highlight *= level
      @highlight
    end

    def path_highlight
      @path_highlight ||= ([highlight] + children.map(&:path_highlight)).max
    end

    def negative_highlight
      - highlight
    end

    def is_highlighted?
      @is_highlighted ||= highlight > 0
    end

    def is_path_highlighted?
      @is_path_highlighted ||= path_highlight > 0
    end

    alias_method :on?, :is_path_highlighted?

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
      @depth ||= - level
    end

    def you_are_elle
      return url unless url.blank? || url == "#"
      return children.first.you_are_elle unless children.empty?
    end

    def link_to opt = {}
      opt.keys.grep(/\!$/).each { |key| o = opt.delete(key) and send key.to_s.gsub /!$/, "?" and opt.merge! o }
      opt.keys.grep(/\?$/).each { |key| o = opt.delete(key) and send key and opt.merge_html! o }      
      template.link_to title, you_are_elle, opt
    end

  end
end

