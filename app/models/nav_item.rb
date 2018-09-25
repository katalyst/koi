class NavItem < ApplicationRecord

  before_save  :raise_abstract_error
  after_save   :after_save
  after_touch  :touch_parent
  after_destroy :after_destroy

  acts_as_nested_set
  has_crud searchable: [:id, :title, :url], settings: false

  crud.config do
    fields parent_id:           { type: :hidden },
           is_hidden:           { type: :boolean },
           link_to_first_child: { type: :boolean },
           alias_id:            { type: :tree },
           if:                  { type: :code },
           unless:              { type: :code },
           method:              { type: :code },
           highlights_on:       { type: :code },
           content_block:       { type: :code }

    config :admin do
      index fields: [:id, :title, :url]
      form  fields: [:title, :url, :is_hidden, :link_to_first_child, :parent_id]
    end
  end

  def raise_abstract_error
    raise "Cannot directly instantiate an Abstract NavItem" if self.class == NavItem
  end

  def titlize
    title
  end

  alias :to_s :titleize

  def is_what?
    raise_abstract_error
  end

  def toggle_hidden!
    update_attribute(:is_hidden, !is_hidden)
  end

  def hidden
    is_hidden? ? "Un-hide" : "Hide"
  end

  def is_hidden?
    is_hidden
  end

  def nav_key
    "key_#{id}"
  end

  def options env = @@binding
    hash = {}
    # Process if any procs in the database if, unless, highlights_on columns
    if self.if.present?
      hash[:if] = Proc.new { eval(self.if, env) }
    end

    if self.unless.present?
      hash[:unless] = Proc.new { eval(self.unless, env) }
    end

    if self.highlights_on.present?
      hash[:highlights_on] = Proc.new { Proc === highlights_on ? highlights_on.call : eval(highlights_on, env) }
    end

    if self.key.present?
      hash[:container_class] = self.key
    end

    if self.method.present?
      hash[:method] = method
    end

    hash
  end

  def is_mobile?
    is_mobile || children.collect { |c| c.is_mobile? }.include?(true)
  end

  def to_hash(show_options = {})
    { mobile: false }.merge(show_options)

    if show_options[:mobile] && !is_mobile?
      return nil
    end

    hash = setup_content(show_options)

    options.delete(:mobile)

    unless options.blank?
      hash[:options] = options
    end

    if link_to_first_child?
      if children.present?
        hash[:url] = children.first.url
      end
    end

    hash
  end

  def to_hashish env = @@binding
    @@binding ||= env
    @to_hashish ||= begin
      hash = as_json except: %w[ navigable_type navigable_id lft rgt created_at updated_at is_mobile ]
      hash[:is_mobile] = read_attribute :is_mobile # is_mobile method is recursive, which we don't want
      hash[:children] = eval content_block, env unless content_block.blank?
      hash.merge! options(env)
    end
  end

  def draggable?
    true
  end

  def navigation(get_binding=binding())
    @children = children
    # if using if/unless/highlights_on, cache the nav items prior to making procs of these fields
    if Koi::Caching.enabled && Koi::Caching.god_nav_tab_enabled 
      @children = Rails.cache.fetch(cache_key, expires_in: 7.days) { children.load }
    end
    # return hash of the navigation structure
    @@binding = get_binding
    @children.collect { |c| c.to_hash unless c.is_hidden }.compact.flatten
  end

  def self.navigation(arg=nil, get_binding=binding())
    self.for(arg).navigation(get_binding)
  end

  def self.for(arg = nil)
    case arg
    when NavItem        then arg
    when Symbol, String then find_by_key arg.to_s
    end or RootNavItem.root
  end

  private

  def setup_content(show_options)
    hash = {}

    if content_block.blank?
      hash = {
        key:   nav_key,
        name:  title,
        url:   url,
        items: children.collect { |c| c.to_hash(show_options) unless c.is_hidden }.compact
      }
    else
      hash = eval(content_block, @@binding)
    end

    hash
  end

  def touch_parent
    parent.touch if parent
  end

  def after_save
    touch_parent
    clear_cache("saving") if Koi::Caching.enabled
  end

  def after_destroy
    clear_cache("deleting") if Koi::Caching.enabled
  end

  def clear_cache(msg)
    Rails.logger.warn("[CACHE CLEAR] - Clearning entire cache after #{msg} #{self.class} #{self.id}")
    Rails.cache.clear
  end

end
