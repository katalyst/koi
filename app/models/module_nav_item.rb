# frozen_string_literal: true

class ModuleNavItem < NavItem
  has_crud searchable: %i[id title url], settings: false

  validates :title, :parent, presence: true
  validates :url, presence: true, unless: :link_to_first_child

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

  def is_what?
    "module"
  end

  def self.title
    "Module"
  end
end
