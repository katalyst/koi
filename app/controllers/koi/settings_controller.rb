module Koi
  class SettingsController < AdminCrudController
    defaults route_prefix: ''

    def new
      @setting = Setting.new(prefix: params[:prefix])
    end
  end
end
