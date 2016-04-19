class RootNavItem < NavItem

  has_crud searchable: [:id, :title, :url], settings: false

  validates :title, presence: true

  crud.config do
    fields parent_id:     { type: :hidden },
           is_hidden:     { type: :boolean },
           is_mobile:     { type: :boolean },
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

  def self.root
    super || RootNavItem.create!({ title: "Home", url: "/", key: "home" })
  end

  def is_what?
    "home"
  end

  def self.title
    "Root"
  end

  def draggable?
    false
  end

end
