class ProductImage < ActiveRecord::Base

  belongs_to :product
  image_accessor :image
  has_crud orderable: true

  ProductTypes = ["Image", "Title"]

  validates :title, presence: true,
            if: "product_type.eql?('Title')"

  validates :image, presence: true,
            if: "product_type.eql?('Image')"

  crud.config do
    fields image: { type: :image },
           product_type: { type: :select, data: ProductTypes }

    config :admin do
      form  fields: [:product_type, :title, :image]
    end
  end

  def product_type
    read_attribute(:product_type) || "Image"
  end

  def inline_titleize
    product_type
  end

end
