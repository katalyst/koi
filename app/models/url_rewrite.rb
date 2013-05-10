class UrlRewrite < ActiveRecord::Base

  has_crud

  validates :from, :to, presence: true

  scope :active, where(active: true)

  def to_s
    "#{from} -> #{to}"
  end

  crud.config do
    fields active: { type: :boolean }

    config :admin do
      index fields: [:from, :to, :active]
    end
  end

end
