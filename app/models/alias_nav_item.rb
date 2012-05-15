class AliasNavItem < NavItem
  validates :title, :alias_id, :parent, presence: true

  crud.config do
    config :admin do
      form fields: [:title, :is_hidden, :is_mobile, :alias_id, :parent_id]
    end
  end

  def is_what?
    "alias"
  end

  def alias_record
    #FIXME: not sure if referencing NavItem here is a good practice
    NavItem.find_by_id(alias_id)
  end

  def url
    alias_record.url if alias_record && !alias_record.is_hidden
  end

  def admin_url
    alias_record.admin_url if alias_record
  end

  def self.title
    "Alias"
  end
end
