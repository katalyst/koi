class NavItem < ActiveRecord::Base
  before_save :raise_abstract_error

  acts_as_nested_set
  has_crud searchable: [:id, :title, :url], settings: false

  crud.config do
    fields parent_id:     { type: :hidden },
             is_hidden:     { type: :boolean },
           alias_id:      { type: :tree },
           if:            { type: :code },
           unless:        { type: :code },
           method:        { type: :code },
           highlights_on: { type: :code },
           content_block: { type: :code }

    config :admin do
      index fields: [:id, :title, :url]
      form  fields: [:title, :url, :is_hidden, :is_mobile, :parent_id]
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

  def options
    hash = {}
    hash[:if] = Proc.new { eval(self.if, @@binding) } unless self.if.blank?
    hash[:unless] = Proc.new { eval(self.unless, @@binding) } unless self.unless.blank?
    hash[:method] = method unless method.blank?
    hash[:highlights_on] = Proc.new { eval(highlights_on, @@binding) } unless highlights_on.blank?
    hash
  end

  def is_mobile?
    is_mobile || children.collect { |c| c.is_mobile? }.include?(true)
  end

  def to_hash(show_options = {})
    { mobile: false }.merge(show_options)
    return nil if show_options[:mobile] && !is_mobile?

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

    options.delete(:mobile)
    hash[:options] = options unless options.blank?
    hash
  end

  def draggable?
    true
  end

  def self.navigation(key=nil, get_binding=binding(), show_options = {})
    @@binding = get_binding
    start = NavItem.find_by_key(key) || RootNavItem.root
    start.children.collect { |c| c.to_hash(show_options) unless c.is_hidden }.compact.flatten
  end
end
