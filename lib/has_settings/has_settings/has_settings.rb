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

      include SharedMethods
    end

    def settings_prefix
      "#{id}.#{self.class.singular_name}"
    end

    def create_settings
      Koi::Settings.resource.each do |key, values|
        unless Setting.find_by_prefix_and_key(settings_prefix, key)
          Setting.create(values.merge(key: key, prefix: settings_prefix))
        end
      end
    end

    include SharedMethods
  end
end
