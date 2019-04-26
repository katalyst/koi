class Category < ApplicationRecord

  has_crud orderable: true, settings: true, navigation: true
  has_many :products, -> { order("ordinal ASC") }, inverse_of: :category

  accepts_nested_attributes_for :products, allow_destroy: true

  crud.config do
    fields products: { type: :inline }

    config :admin do
      form  fields:    [:name, :products]
      index fields:    [:name],
            relations: [:products]
      csv   fields:    [:created_at, :name, :products]
    end
  end

  def to_s
    name
  end

end
