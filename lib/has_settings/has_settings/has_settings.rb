require_relative 'shared_methods'

module HasSettings
  def has_settings(options={})
    send :include, HasSettings::Model
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

    include SharedMethods
  end
end
