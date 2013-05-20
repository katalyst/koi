module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def new
      @setting = Setting.new(prefix: params[:prefix])
    end

    def create
      create! { resource.prefix.present? ? request.referer : { action: :index } }
    end

    def update
      update! { resource.prefix.present? ? request.referer : { action: :index } }
    end

  end
end
