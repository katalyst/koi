class Category < ActiveRecord::Base

  has_crud orderable: true, settings: true
  has_many :products, -> { order("ordinal ASC") }

  accepts_nested_attributes_for :products, allow_destroy: true

  crud.config do
    fields products: { type: :inline }

    config :admin do
      form  fields:    [:name, :products]
      index fields:    [:name],
            relations: [:products]
    end
  end

  def to_s
    name
  end

end
