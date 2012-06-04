module HasSettings
  module SharedMethods
    def settings
      Setting.where(prefix: settings_prefix)
    end

    def setting(key, default=nil)
      Setting.find_by_prefix_and_key(settings_prefix, key).try(:value) || default
    end
  end
end
