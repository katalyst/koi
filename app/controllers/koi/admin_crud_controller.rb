module Koi
  class AdminCrudController < Koi::ApplicationController
    has_crud :admin => true
    # defaults :route_prefix => 'admin'

    def show
      redirect_to edit_resource_path
    end
  end
end
