# frozen_string_literal: true

module Koi
  class AdminsController < AdminCrudController
    defaults resource_class: AdminUser, route_prefix: ""

    def update_resource(object, attributes)
      if params[:admin][:password].blank? && params[:admin][:password_confirmation].blank?
        object.update_without_password(*attributes)
      else
        object.update(*attributes)
      end
    end
  end
end
