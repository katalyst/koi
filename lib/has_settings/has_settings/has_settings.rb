module HasSettings
  def has_settings(options={})
    # Include class & instance methods.
    send :include, HasSettings::Model
  end

  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      def singular_name
        to_s.underscore
      end

      def settings
        Translation.where("`key` LIKE ?", "#{singular_name}.%")
      end

      def setting(key, default=nil)
        Translation.find_by_key("#{singular_name}.#{key}").try(:value) || default
      end
    end

    def singular_name
      self.class.singular_name
    end

    def settings
      Translation.where("`key` LIKE ?", "#{id}.#{singular_name}.%")
    end

    def setting(key, default=nil)
      Translation.find_by_key("#{id}.#{singular_name}.#{key}").try(:value) || default
    end
  end
end
