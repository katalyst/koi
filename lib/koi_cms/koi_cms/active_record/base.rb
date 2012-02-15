require_relative '_'

module ActiveRecord

  Base.class_eval do

    def self.associations
      reflect_on_all_associations.map(&:name)
    end

    def self.nested_associations
      reflect_on_all_associations.select(&:is_nested?).map(&:name)
    end

    def self.validates_presence_of?(name)
      validators_on(name).any? do |v|
        v.instance_of? ActiveModel::Validations::PresenceValidator
      end
    end

    def self.ordinal_name
      attributes.find {|s| /ordinal/ === s}
    end

    def count(name)
      value = send name
      value.nil? ? 0 : value.instance_of?(Array) ? value.size : 1
    end

    def as_json(opt)
    	super opt.merge(include: self.class.nested_associations)
    end

    def to_params(opt = {})
      params = as_json(opt)[self.class.name.downcase]
      keys = params.keys & self.class.associations
      params.each { |k| hash["#{k}_attributes"] = param.delete(k) }
    end

  end

end