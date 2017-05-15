class UrlRewrite < ApplicationRecord

  has_crud

  validates :from, :to, presence: true

  scope :active, -> { where(active: true) }

  def to_s
    "#{from} -> #{to}"
  end

  crud.config do
    fields active: { type: :boolean }

    config :admin do
      index fields: [:from, :to, :active]
    end
  end

  def self.redirect_path_for(path)
    active.find_by_from(path).try(:to)
  end

end
