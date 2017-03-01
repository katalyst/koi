class Product < ActiveRecord::Base

  has_crud orderable: true, settings: true
  has_many :product_images
  accepts_nested_attributes_for :product_images, allow_destroy: true

  belongs_to :category

  # FIXME: Refactored from has
  has_many :images

  has_and_belongs_to_many :products,
    join_table: "related_products",
    foreign_key: "product_a_id",
    association_foreign_key: "product_b_id"

  acts_as_taggable_on :genre
  serialize :countries

  dragonfly_accessor :banner
  dragonfly_accessor  :manual

  Size = ["XL", "L", "M", "S", "XS"]
  Countries = ["Australia", "France", "Germany", "Greece"]

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
           colour: { type: :colour },
           banner: { type: :image },
           manual: { type: :file },
           products: { type: :multiselect_association },
           product_images: { type: :inline },
           description: { type: :rich_text },
           launch_date: { type: :mask, mask_type: "00/00/0000" }

    config :admin do
      index fields: [:name]
       form  fields: [:name, :description, :launch_date, :colour, :products, :product_images]
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
