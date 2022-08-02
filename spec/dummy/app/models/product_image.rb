# frozen_string_literal: true

class ProductImage < ApplicationRecord
  belongs_to :product
  dragonfly_accessor :image
  has_crud orderable: true

  PRODUCT_TYPES = %w[Image Title].freeze

  validates :title, presence: true,
                    if:       -> { product_type.eql?("Title") }

  validates :image, presence: true,
                    if:       -> { product_type.eql?("Image") }

  crud.config do
    fields image:        { type: :image },
           product_type: { type: :select, data: PRODUCT_TYPES }

    config :admin do
      form fields: %i[product_type title image]
      show fields: %i[product_type title image]
    end
  end

  def product_type
    read_attribute(:product_type) || "Image"
  end

  def inline_titleize
    product_type
  end
end
