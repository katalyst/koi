class Product < ActiveRecord::Base

  has_crud orderable: true, settings: true
  has_many :product_images
  accepts_nested_attributes_for :product_images, allow_destroy: true

  belongs_to :category

  has :many, attributed: :images, orderable: true
  has_and_belongs_to_many :products,
    join_table: "related_products",
    foreign_key: "product_a_id",
    association_foreign_key: "product_b_id"

  acts_as_taggable_on :genre
  serialize :countries

  image_accessor :banner
  file_accessor  :manual

  Size = ["XL", "L", "M", "S", "XS"]
  Countries = ["Australia", "France", "Germany", "Greece"]
  Colours = ["Red", "Blue", "Green"]

  validates :name, presence: true

  # validates :name, :short_description, :description,
  #           :publish_date, :launch_date, :genre_list,
  #           :banner, :manual, :size, :colour,
  #           presence: true

  # validate :at_least_one_country

  def at_least_one_country
    errors.add :countries, "Please select at least one country" if countries.blank? || countries.reject(&:blank?).compact.empty?
  end

  crud.config do
    fields launch_date: { type: :date },
           short_description: { type: :text },
           genre_list: { type: :nice_tags },
           active: { type: :boolean },
           size: { type: :select, data: Size },
           countries: { type: :check_boxes, data: Countries },
           colour: { type: :radio, data: Colours },
           banner: { type: :image },
           manual: { type: :file },
           products: { type: :multiselect_association },
           product_images: { type: :inline }

    config :admin do
      index fields: [:name]
       form  fields: [:name, :description, :products, :product_images]
    end
  end

  def to_s
    name
  end

  def inline_titleize
    if new_record?
      "Product"
    else
      to_s
    end
  end

end
