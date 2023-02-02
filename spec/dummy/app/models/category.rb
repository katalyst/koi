# frozen_string_literal: true

class Category < ApplicationRecord
  has_crud orderable: true
  has_many :products, -> { order("ordinal ASC") }

  accepts_nested_attributes_for :products, allow_destroy: true

  crud.config do
    fields products: { type: :inline }

    config :admin do
      form  fields: %i[name products]
      index fields:    [:name],
            relations: [:products]
      csv   fields:    %i[created_at name products]
    end
  end

  def to_s
    name
  end
end
