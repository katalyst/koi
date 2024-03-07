# frozen_string_literal: true

module Koi
  class SettingsController < TranslationsController
    defaults resource_class: Setting

    def new
      @setting = Setting.new(prefix: params[:prefix])
    end

    def create
      create! { resource.prefix.present? ? "#{request.referer}#tab-extra" : { action: :index } }
    end

    def update
      update! { resource.prefix.present? ? "#{request.referer}#tab-extra" : { action: :index } }
    end

    def update_multiple
      params[:setting].each do |key, data|
        setting_id = key.delete_prefix("setting_")
        next unless /\A\d+\z/.match?(setting_id)

        @setting = Setting.find(setting_id.to_i)
        @setting.update(value: data[:value])
      end

      params[:group] = "main" if params[:group].blank?

      redirect_to(request.referer + "#tab-#{params[:group]}")
    end
  end
end
