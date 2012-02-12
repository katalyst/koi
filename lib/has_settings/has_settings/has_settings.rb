module HasSettings
  def has_settings(options={})
    # Include url helpers to generate default path.
    send :include, Rails.application.routes.url_helpers
    # Include class & instance methods.
    send :include, HasSettings::Model

    has_one :setting, as: :set, dependent: :destroy
    after_save :update_path
  end

  module Model
    extend ActiveSupport::Concern

    def to_setting(options={})
      options.merge!(:set => self)
      setting = setting.blank? ? Koi::Setting.new : setting
      setting.attributes = options.merge(url: polymorphic_path(self))
      setting
    end

    def to_setting!(options={})
      set = to_setting(options)
      set.save
    end

    #FIXME: Hook not working, need this to update the url of setting automattically after record url is updated.
    def update_path
      setting.update_attribute(:url, polymorphic_path(self)) if setting rescue NoMethodError
    end
  end
end

