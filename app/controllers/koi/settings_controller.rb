module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def back_path
      request.referer + '#tab-settings'
    end

    def new
      @setting = Setting.new prefix: params[:prefix]
    end

    def create
      create! { resource.prefix.present? ? back_path : collection_path }
    end

    def update
      update! { resource.prefix.present? ? back_path : collection_path }
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
