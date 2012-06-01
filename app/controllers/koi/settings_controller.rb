module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def new
      @setting = Setting.new(prefix: params[:prefix])
    end
  end
end
