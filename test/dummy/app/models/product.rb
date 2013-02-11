class Product < ActiveRecord::Base

  has_crud orderable: true
  belongs_to :category
  has :many, attributed: :images, orderable: true
  acts_as_taggable_on :genre
  serialize :countries

  image_accessor :banner
  file_accessor  :manual

  Size = ["XL", "L", "M", "S", "XS"]
  Countries = ["Australia", "France", "Germany", "Greece"]
  Colours = ["Red", "Blue", "Green"]

  validates :name, presence: true

  crud.config do
    fields launch_date: { type: :date },
           short_description: { type: :text },
           genre_list: { type: :tags },
           active: { type: :boolean },
           size: { type: :select, data: Size },
           countries: { type: :check_boxes, data: Countries },
           colour: { type: :radio, data: Colours },
           banner: { type: :image },
           manual: { type: :file }

    config :admin do
      index fields: [:name]
      form  fields: [:name, :short_description, :description,
                     :publish_date, :launch_date, :genre_list,
                     :banner, :manual, :size, :countries,
                     :colour, :active, :images]
    end
  end

  def to_s
    name
  end

end

