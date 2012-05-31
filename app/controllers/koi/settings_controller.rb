module Koi
  class SettingsController < AdminCrudController
    defaults route_prefix:    '',
             resource_class:  Translation,
             collection_name: 'settings',
             instance_name:   'setting'

    def create
      create! do |success, failure|
        success.html { redirect_to redirect_path }
        success.js
        failure.js
      end
    end

    def update
      update! do |success, failure|
        success.html { redirect_to redirect_path }
        success.js
        failure.js
      end
    end

    def destroy
      destroy! do |format|
        format.html { redirect_to redirect_path }
        format.js
      end
    end
  end
end
