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

    # TODO: Get me supporting files, images etc.
    def update_multiple
      params['setting'].keys.each do |id|
        @setting = Setting.find(id.to_i)
        @setting.update_attributes(params['setting'][id])
      end
      redirect_to(request.referer + '#tab-settings')
    end

  end
end
