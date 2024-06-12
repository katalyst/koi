# frozen_string_literal: true

class Banner < ApplicationRecord
  enum :status, { draft: 0, published: 1, archived: 2 }, default: :draft

  has_one_attached :image do |image|
    image.variant :thumb, resize_to_fill: [100, 100]
  end

  scope :admin_search, ->(query) do
    where("name LIKE :query", query: "%#{query}%")
  end

  default_scope -> { order(ordinal: :asc) }
end
