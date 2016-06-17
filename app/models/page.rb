class Page < ActiveRecord::Base
  has_crud paginate: false, navigation: true,
           settings: true

  has_many :page_page_contents
  has_many :page_contents, through: :page_page_contents
  accepts_nested_attributes_for :page_contents, allow_destroy: true

  validates_presence_of :title

  def titleize
    title
  end

  def to_s
    title
  end

  crud.config do
    actions only: [:index, :show]
    hide false
    title collection: "Pages"
    fields page_contents: { type: :inline }
    config :admin do
      actions except: [:new]
      index   fields: [:id, :title]
      form    fields: [:title, :page_contents]
    end
  end
end
