module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def back_path
      resource.prefix.present? ? request.referer + '#tab-settings' : collection_path
    end

    def new
      @setting = Setting.new prefix: params[:prefix]
    end

    def create
      create! { back_path }
    end

    def update
      update! { back_path }
    end

    def bulk_create_or_update
      return redirect_to :back if params[:settings].blank?
      return redirect_to :back if params[:settings][:settings_attributes].blank?
      
      params[:settings][:settings_attributes].values.each do |hash|
        id = hash.delete :id
        Setting.find(id.to_i).update_attributes! hash
      end
      
      return redirect_to back_path
    end

  end
end
