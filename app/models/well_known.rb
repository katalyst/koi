# frozen_string_literal: true

class WellKnown < ApplicationRecord
  CONTENT_TYPES = {
    text: "text/plain",
    json: "application/json",
  }.freeze

  enum :content_type, CONTENT_TYPES

  validates :name, :purpose, :content_type, presence: true
  validates :name, uniqueness: { case_sensitive: true }

  scope :admin_search, ->(query) do
    where(arel_table[:name].matches("%#{query}%"))
  end

  def format
    content_type.to_sym
  end

  def to_s
    name
  end
end
