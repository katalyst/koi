# frozen_string_literal: true

class UrlRewrite < ApplicationRecord
  include Koi::Model

  has_crud

  validates :from, :to, presence: true

  scope :active, -> { where(active: true) }

  def to_s
    "#{from} -> #{to}"
  end

  crud.config do
    fields active: { type: :boolean }

    config :admin do
      index fields: %i[from to active]
    end
  end

  def self.redirect_path_for(path)
    active.find_by(from: path).try(:to)
  end
end
