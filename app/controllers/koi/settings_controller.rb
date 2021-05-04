module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def new
      @setting = Setting.new(prefix: params[:prefix])
    end

    def create
      create! { resource.prefix.present? ? request.referer + '#tab-settings' : { action: :index } }
    end

    def update
      update! { resource.prefix.present? ? request.referer + '#tab-settings' : { action: :index } }
    end

    def update_multiple
      params[:setting][:setting].each do |id, value|
        @setting = Setting.find(id.to_i)
        @setting.update(params[:setting][:setting][id])
      end

      params[:group] = 'main' if params[:group].blank?

      redirect_to(request.referer + "#tab-#{params[:group]}")
    end

  end
end
