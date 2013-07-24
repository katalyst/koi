module HasSettings
  module SharedMethods

    def setting(key, value=nil, opt={})
      options = {
        key:    key.to_s,
        label:  key.to_s.titleize,
        field_type: 'rich_text',
        value:  value
      }.merge(opt).merge({
        prefix: settings_prefix
      })

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
