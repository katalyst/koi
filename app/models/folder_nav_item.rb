class FolderNavItem < NavItem

  has_crud searchable: [:id, :title, :url], settings: false

  validates :title, :parent, presence: true

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
      form  fields: [:title, :is_hidden, :link_to_first_child, :parent_id]
    end
  end

  def is_what?
    "folder"
  end

  # def draggable?
  #   parent.eql?(root) ? false : true
  # end

  def self.title
    "Folder"
  end

end
