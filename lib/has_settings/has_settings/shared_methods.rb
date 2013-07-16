module HasSettings
  module SharedMethods

    def setting(key, default_value=nil, default_type='rich_text')
      options = {
        key:    key.to_s,
        label:  key.to_s.titleize,
        prefix: settings_prefix,
        field_type: default_type,
        value:  default_value
      }

      setting = Setting.find_by_prefix_and_key(settings_prefix, key) || Setting.create(options)
      setting.value
    end

    def create_setting(key, values)
      unless Setting.find_by_prefix_and_key(settings_prefix, key)
        Setting.create(values.merge(key: key, prefix: settings_prefix))
      end
    end

  end
end
