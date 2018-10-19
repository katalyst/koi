class Page < ApplicationRecord
  include Composable

  has_crud paginate: false, navigation: true,
           settings: true

  validates_presence_of :title

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do
    fields composable_data: { type: :composable }
    actions only: [:index, :show]
    hide false
    title collection: "Pages"
    config :admin do
      actions except: [:new]
      index   fields: [:id, :title]
      form    fields: [:title, :composable_data],
              composable: ["section", "heading", "text", "rich_text", "hero", "hero_list", "kitchen_sink"]
    end
  end

  # overriding has_navigation methods to work with koi page route namespacing
  def self.get_new_admin_url(options={})
    Koi::Engine.routes.url_helpers.new_page_path(options)
  end

  def get_edit_admin_url(options={})
    Koi::Engine.routes.url_helpers.edit_page_path(self, options)
  end

end
