require_relative 'shared_methods'

module HasSettings
  def has_settings(options={})
    send :include, HasSettings::Model
    send :after_save, :create_settings
  end

  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def singular_name
        to_s.underscore
      end

      def settings_prefix
        "#{singular_name}"
      end

      def settings
        Setting.where(prefix: settings_prefix).collect do |setting|
          setting.derive_data_source(true)
          setting
        end
      end

      include SharedMethods
    end

    def settings
      Setting.where(prefix: settings_prefix)
    end

    def settings_prefix
      "#{id}.#{self.class.singular_name}"
    end

    def create_settings
      Koi::Settings.resource.each do |key, values|
        create_setting(key, values)
      end
    end

    include SharedMethods
  end
end
