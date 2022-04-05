# frozen_string_literal: true

class RootNavItem < NavItem
  has_crud searchable: %i[id title url], settings: false

  validates :title, presence: true

  crud.config do
    fields parent_id: { type: :hidden },
           is_hidden: { type: :boolean },
           alias_id:  { type: :tree },
           method:    { type: :code }

    config :admin do
      index fields: %i[id title url]
      form  fields: %i[title url is_hidden parent_id]
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
