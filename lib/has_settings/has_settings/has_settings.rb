# frozen_string_literal: true

require_relative "shared_methods"

module HasSettings
  extend ActiveSupport::Concern

  class_methods do
    def has_settings(_options = {})
      send :include, HasSettings::Model
      send :after_save, :create_settings
      send :before_destroy, :remove_settings
    end
  end

  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def singular_name
        to_s.underscore
      end

      def settings_prefix
        singular_name.to_s
      end

      def settings
        Setting.where(prefix: settings_prefix).map do |setting|
          setting.derive_data_source(collection: true)
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

    def underscore_class_name
      self.class.name.underscore.to_sym
    end

    def create_settings
      return true if Koi::Settings.skip_on_create.include?(underscore_class_name)

      Koi::Settings.resource.each do |key, values|
        create_setting(key, values)
      end
    end

    def remove_settings
      settings.destroy_all
    end

    include SharedMethods
  end
end
