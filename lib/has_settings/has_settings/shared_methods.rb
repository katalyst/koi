module HasSettings
  module SharedMethods
    def settings
      Setting.where(prefix: settings_prefix)
    end

    def setting(key, default=nil)
      options = {
        key:    key.to_s,
        label:  key.to_s.titleize,
        prefix: settings_prefix,
        value:  default
      }

      Setting.find_by_prefix_and_key(settings_prefix, key) || Setting.create(options)
    end
  end
end
