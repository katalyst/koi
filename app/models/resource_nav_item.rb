# frozen_string_literal: true

class ResourceNavItem < NavItem
  has_crud searchable: %i[id title url], settings: false

  belongs_to :navigable, polymorphic: true

  validates :title, :parent, :url, :admin_url, presence: true

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
    "page"
  end

  def title
    write_attribute :title, navigable.try((TITLE & navigable.methods).first) and save if read_attribute(:title).blank?
    read_attribute :title
  end

  TITLE = %i[title name heading to_s].freeze
end
