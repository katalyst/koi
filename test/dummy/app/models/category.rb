class Category < ActiveRecord::Base
  has_crud :orderable => true
  has_many :products

  crud.config do
    config :admin do
      index fields: [:name],
            relations: [:products]
    end
  end
end

