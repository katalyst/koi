class Admin::ProductsController < Koi::AdminCrudController
  belongs_to :category
end

