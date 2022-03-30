# frozen_string_literal: true

class NavItem < ApplicationRecord
  before_save :raise_abstract_error
  after_destroy :clear_cache
  after_save :touch_parent, :clear_cache
  after_touch :touch_parent

  acts_as_nested_set
  has_crud searchable: %i[id title url], settings: false

  crud.config do
    fields parent_id:           { type: :hidden },
           is_hidden:           { type: :boolean },
           link_to_first_child: { type: :boolean },
           alias_id:            { type: :tree },
           method:              { type: :code }

    config :admin do
      index fields: %i[id title url]
      form  fields: %i[title url is_hidden link_to_first_child parent_id]
    end
  end

  scope :visible, -> { where(is_hidden: false) }

  def raise_abstract_error
    raise "Cannot directly instantiate an Abstract NavItem" if instance_of?(NavItem)
  end

  def titlize
    title
  end

  alias to_s titleize

  def is_what?
    raise_abstract_error
  end

  def toggle_hidden!
    update!(is_hidden: !is_hidden)
  end

  def hidden
    is_hidden? ? "Un-hide" : "Hide"
  end

  def hidden?
    is_hidden
  end

  alias is_hidden? hidden?

  def nav_key
    "key_#{id}"
  end

  def mobile?
    is_mobile || children.any?(&:mobile?)
  end

  alias is_mobile? mobile?

  def to_hash(mobile: false)
    return nil if mobile && !is_mobile?

    hash  = nav_content
    items = navigation(mobile: mobile)

    hash[:items] = items if items.any?

    hash
  end

  def draggable?
    true
  end

  def navigation(**options)
    children.reject(&:hidden?).map { |child| child.to_hash(**options) }
  end

  # Returns the next item in the alias chain, or self
  def alias_record
    link_to_first_child? ? children.visible.first : self
  end

  def url
    # DO NOT call url here, any redirection should happen through `alias_record` not through `url`
    NavItem.aliased(self)&.read_attribute(:url)
  end

  def admin_url
    NavItem.aliased(self)&.read_attribute(:admin_url)
  end

  # Traverses alias chain until fixed point or loop is reached
  def self.aliased(nav_item)
    seen = Set.new

    while nav_item.present? && seen.exclude?(nav_item)
      seen.add(nav_item)
      nav_item = nav_item.alias_record
    end

    nav_item
  end

  def self.navigation(arg = nil)
    self.for(arg).navigation
  end

  def self.for(arg = nil)
    case arg
    when NavItem        then arg
    when Symbol, String then find_by key: arg.to_s
    end or RootNavItem.root
  end

  private

  def nav_content
    {
      key:     nav_key,
      name:    title,
      url:     url,
      options: nav_options,
    }
  end

  def nav_options
    options                        = {}

    options[:container_class]      = key if key.present?
    options[:method]               = method if method.present?
    options[:"data-nav-item-type"] = self.class.name

    options
  end

  def touch_parent
    parent&.touch # rubocop:disable Rails/SkipsModelValidations
  end

  def clear_cache
    if Koi::Caching.enabled
      Rails.logger.warn("[CACHE CLEAR] - Clearing entire cache due to nav change: #{self.class} #{id}")
      Rails.cache.clear
    end
  end
end
