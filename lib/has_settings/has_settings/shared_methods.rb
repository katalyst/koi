module HasSettings
  module SharedMethods
    def settings
      Setting.where(prefix: settings_prefix)
    end

    def settings_hash
      hash = settings.each_with_object Hash.new do |setting, hash|
        hash[setting.key.to_sym] = setting.value unless setting.value.blank?
      end
      hash.reverse_merge! self.class.settings_hash if self.class.respond_to? :settings_hash
      hash
    end

    def setting(key, default=nil)
      options = {
        key:    key.to_s,
        label:  key.to_s.titleize,
        prefix: settings_prefix,
        field_type: "rich_text",
        value:  default
      }

      setting = Setting.find_by_prefix_and_key(settings_prefix, key) || Setting.create(options)
      setting.value
    end
  end
end
