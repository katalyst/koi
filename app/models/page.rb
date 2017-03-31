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
      form    fields: [:title, :description, :composable_data]
    end
  end

  # overriding has_navigation methods to work with koi page route namespacing
  def self.get_new_admin_url(options={})
    Koi::Engine.routes.url_helpers.new_page_path(options)
  end

  def get_edit_admin_url(options={})
    Koi::Engine.routes.url_helpers.edit_page_path(self, options)
  end

  def self.field_types 
    [{
      name: "Section",
      slug: "section",
      fields: [{
        label: "Section Type",
        name: "section_type",
        type: "select", 
        className: "form--auto",
        data: ["body", "fullwidth"] 
      }]
    },{
      name: "Heading",
      slug: "heading",
      fields: [{
        label: "Heading Text",
        name: "text",
        type: "string",
        className: "form--medium"
      },{
        label: "Size",
        name: "heading_size",
        type: "select",
        data: ["1", "2", "3", "4", "5", "6"],
        className: "form--auto"
      }]
    },{
      name: "Text",
      slug: "text",
      fields: [{
        name: "body",
        type: "textarea"
      }]
    }]
  end

end
