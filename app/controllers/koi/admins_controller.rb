module Koi
  class AdminsController < AdminCrudController
    defaults :route_prefix => ''

    def update_resource(object, attributes)
      if params[:admin][:password].blank? && params[:admin][:password_confirmation].blank?
        object.update_without_password(*attributes)
      else
        object.update_attributes(*attributes)
      end
    end
  end
end
