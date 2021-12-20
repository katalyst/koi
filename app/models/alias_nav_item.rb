# frozen_string_literal: true

class AliasNavItem < NavItem
  has_crud searchable: %i[id title url], settings: false

  validates :title, :alias_id, :parent, presence: true

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
      index fields: %i[id title url]
      form fields: %i[title is_hidden alias_id parent_id]
    end
  end

  def is_what?
    "alias"
  end

  def alias_record
    NavItem.find_by(id: alias_id, is_hidden: false)
  end

  def self.title
    "Alias"
  end
end
