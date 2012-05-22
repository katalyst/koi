module HasSettings
  module SharedMethods
    def settings
      Translation.where("`key` LIKE ?", "#{prefix}.%")
    end

    def setting(key, default=nil)
      Translation.find_by_key("#{prefix}.#{key}").try(:value) || default
    end

    def find_or_create_setting(options={})
      options[:key] = "#{prefix}.#{options[:key]}"
      Translation.find_or_create_by_key(options)
    end

    def create_setting(options={})
      options[:key] = "#{prefix}.#{options[:key]}"
      Translation.create(options)
    end
  end
end
