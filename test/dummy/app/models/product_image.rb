class ProductImage < ActiveRecord::Base

  belongs_to :product
  image_accessor :image
  has_crud orderable: true

  crud.config do
    fields image: { type: :image }

    config :admin do
      form  fields: [:image]
    end
  end

end

