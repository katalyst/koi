class Page < ApplicationRecord
  has_crud paginate: false, navigation: true,
           settings: true, composable: true

  validates :title, presence: true
  composable :body, components: [:section, :heading, :text]

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do
    fields body: { type: :composable }
    actions only: [:index, :show]
    hide false
    title collection: "Pages"
    config :admin do
      actions except: [:new]
      index   fields: [:id, :title]
      form    fields: [:title, :description, :body]
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
