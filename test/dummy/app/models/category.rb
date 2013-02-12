class Category < ActiveRecord::Base

  has_crud
  has_many :products

  crud.config do
    config :admin do
      index fields:    [:name],
            relations: [:products]
    end
  end

  def to_s
    name
  end

end
