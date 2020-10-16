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

      setting = Setting.find_by_prefix_and_key(settings_prefix, key)

      setting = if setting.nil? && options != default_setting_options(key)
                  Setting.create(options)
                else
                  Setting.new(options)
                end

      setting_value(setting)
    end

    def create_setting(key, values)
      unless Setting.find_by_prefix_and_key(settings_prefix, key)
        values.delete(:group) unless Setting.columns.map{ |c| c.name }.include?('group')
        Setting.create(values.merge(key: key, prefix: settings_prefix))
      end
    end

    def grouped_settings
      settings.group_by(&:group).reject { |group| except_these_groups.include?(group) }
    end

    def except_these_groups
      []
    end

    private

    def default_setting_options(key)
      {
        key:    key.to_s,
        label:  key.to_s.titleize,
        field_type: 'rich_text',
        prefix: settings_prefix,
        value:  nil
      }
    end

    def setting_value(setting)
      case setting.field_type.to_s
      when "check_boxes"
        setting.serialized_value
      when "file"
        setting.file
      when "image"
        setting.file
      when "boolean"
        !!setting.value.to_s.eql?("1")
      when "tags"
        setting.tags
      else
        setting.value
      end
    end
  end
end
