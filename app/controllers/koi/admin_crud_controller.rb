module Koi
  class AdminCrudController < ApplicationController
    has_crud :admin => true

    def show
      redirect_to edit_resource_path
    end
  end
end
