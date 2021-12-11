# frozen_string_literal: true

class ProductsController < CrudController
  belongs_to :category
end
