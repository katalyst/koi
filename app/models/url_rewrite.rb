# frozen_string_literal: true

class UrlRewrite < ApplicationRecord
  validates :from, :to, presence: true
  validates :from, format: { with: %r{\A/.*\z}, message: "should start with /" }

  scope :active, -> { where(active: true) }
  scope :alphabetical, -> { order(from: :asc) }

  def to_s
    "#{from} -> #{to}"
  end

  scope :admin_search, ->(query) do
    where(arel_table[:from].matches("%#{query}%").or(arel_table[:to].matches("%#{query}%")))
  end

  def self.redirect_path_for(path)
    active.find_by(from: path).try(:to)
  end
end
