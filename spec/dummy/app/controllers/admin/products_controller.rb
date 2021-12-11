# frozen_string_literal: true

module Admin
  class ProductsController < Koi::AdminCrudController
    belongs_to :category
  end
end
