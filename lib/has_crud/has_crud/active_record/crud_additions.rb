module HasCrud
  module ActiveRecord
    module CrudAdditions
      extend ActiveSupport::Concern
      module ClassMethods
        def attributes(type=nil)
          (crud.find(type, :fields) || default_attributes) -
            (crud.find(type, :except) || [])
        end

        def default_attributes
          columns.collect { |c| map_attribute(c.name.to_sym) } - crud.find(:ignore)
        end

        def admin_attributes(type=nil)
          (crud.find(:admin, type, :fields) || admin_default_attributes) -
            (crud.find(:admin, type, :except) || [])
        end

        def admin_default_attributes
          columns.collect { |c| map_attribute(c.name.to_sym) } - crud.find(:admin, :ignore)
        end

        def map_attribute(attr)
          (crud.find(:map, attr) || attr).to_sym
        end

        def orderable(ids)
          # FIXME: Check ids sanitisation
          update_all(["ordinal = STRPOS(?, ','||id||',')", ",#{ids.join(',')},"])
        end

        def titleize
          crud.find(:title, :collection) || self.to_s.underscore.humanize.titleize.pluralize
        end

        def show_in_menu?
          crud.find(:hide).eql?(true) ? false : true
        end

        def admin_path
          [:admin, self]
        end

        def has_crud?
          true
        end

        def validates_presence_of?(name)
          validators_on(name).any? do |v|
            v.instance_of? ActiveModel::Validations::PresenceValidator
          end
        end
      end

      # Only models that use 'has_crud' will get these instance methods:
      def titleize
        new_record? ? self.class.titleize.singularize : to_s.titleize.singularize
      end
    end
  end
end

