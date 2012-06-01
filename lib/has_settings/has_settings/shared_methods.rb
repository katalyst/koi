module HasSettings
  module SharedMethods
    def settings
      Setting.where(prefix: settings_prefix)
    end

    def setting(key, default=nil)
      Setting.find_by_prefix_and_key(settings_prefix, key).try(:value) || default
    end

    def find_or_create_setting(key)
      Setting.find_or_create_by_prefix_and_key(settings_prefix, options[:key])
    end

    def create_setting(options={})
      options[:prefix] = settings_prefix
      Setting.create(options)
    end
  end
end
