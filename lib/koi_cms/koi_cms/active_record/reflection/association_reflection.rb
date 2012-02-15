require_relative '_'

module ActiveRecord::Reflection

  AssociationReflection.class_eval do

    def ordinal_name
      klass.ordinal_name
    end

    def is_orderable?
      options[:order] == ordinal_name
    end

    def is_required?
      active_record.validates_presence_of? name
    end

    def is_dependent?
      options[:autosave] && options[:dependent] == :destroy
    end

    def is_nested?
      active_record.method_defined?("#{name}_attributes=") && is_dependent?
    end

    def minimum
      is_required? ? 1 : 0
    end

    def maximum
      (macro == :has_many) ? (options[:limit] || (Infinity)) : 1
    end

    def range
      minimum..maximum
    end

    def minimum_maximum
      [mininum, maximum]
    end

  end

end
