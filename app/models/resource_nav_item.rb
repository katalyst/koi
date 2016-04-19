class ResourceNavItem < NavItem

  has_crud searchable: [:id, :title, :url], settings: false

  belongs_to :navigable, :polymorphic => true

  validates :title, :parent, :url, :admin_url, presence: true

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

  def is_what?
    "page"
  end

  def title
    write_attribute :title, navigable.try((TITLE & navigable.methods).first) and save if read_attribute(:title).blank?
    read_attribute :title
  end

  TITLE = [:title, :name, :heading, :to_s]

end
