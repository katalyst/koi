class Product < ActiveRecord::Base
  has_crud
  validates :name, presence: true

  crud.config do
    config :admin do
      index fields: [:name]
      form fields: [:name, :description]
    end
  end

  def to_s
    name
  end
end

