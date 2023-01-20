# frozen_string_literal: true

module Exportable
  extend ActiveSupport::Concern

  class_methods do
    def make_exportable
      send :include, Exportable::Model
    end
  end

  module Model
    extend ActiveSupport::Concern

    class_methods do
      #
      # MyModel.active.ordered.to_formatted_csv
      #
      # =>  my_field, my_other_field
      #     value_1, value_2
      #     value_1, value_2
      #     ...etc
      #
      # Custom field types defined in crud fields can be given custom formatting by
      # defining a method like so (say, for the field crazy_field: { type: :crazy_type }):
      #
      #
      # def self.csv_format_crazy_type(object, attr)
      #   value = object.send(attr)
      #   #do something with the value
      # end
      #
      # - If you don't pass in attributes, it'll use the fields defined in admin crud csv fields
      # - if crud csv fields don't exist, it'll use the column names.
      #

      def to_formatted_csv(*attributes)
        attributes = crud.find(:admin, :csv, :fields) if attributes.blank?
        attributes = column_names.map(&:to_sym) if attributes.blank?

        CSV.generate(headers: true) do |csv|
          header_row = attributes.map do |attr|
            I18n.t "simple_form.labels.#{name.underscore}.#{attr}", default: attr.to_s.titleize
          end
          csv << header_row
          all.each do |object|
            csv << attributes.map { |attr| format_field_for_csv attr, object }
          end
        end
      end

      # get field definitions from crud config, e.g.
      #
      #  [
      #    active: { type: boolean },
      #    description: { type: :text },
      #  ]
      #
      def field_definitions
        @field_definitions ||= crud.find(:fields)
      end

      # e.g.
      #
      #  format_field_for_csv(:boolean, <record>, :active)
      #  => "Yes"
      #
      def format_field_for_csv(attr, object)
        field_definition = field_definitions[attr]
        field_type       = field_definition[:type] if field_definition.present?

        if can_format_for_csv?(field_type)
          send(csv_format_field_method_name(field_type), object, attr)
        else
          guess_format_for_csv(object, attr)
        end
      end

      # work out whether (e.g.) a `csv_format_boolean` method exists
      def can_format_for_csv?(field_type)
        respond_to?(csv_format_field_method_name(field_type), true) # `true` here ensures that it'll search for private methods
      end

      # e.g. csv_format_boolean
      def csv_format_field_method_name(field_type)
        "csv_format_#{field_type}"
      end

      # guess the format from the value's data type, to ensure consistent formatting of dates, booleans, etc
      def guess_format_for_csv(object, attr)
        value = object.send(attr)
        case value
        when Date
          csv_format_date(object, attr)
        when DateTime, ActiveSupport::TimeWithZone
          csv_format_datetime(object, attr)
        when Time
          csv_format_time(object, attr)
        when TrueClass, FalseClass
          csv_format_boolean(object, attr)
        when Array
          csv_format_array(object, attr)
        else
          # use the raw value
          object.send(attr)
        end
      end

      #
      # Methods to format specific types of fields
      #

      def csv_format_boolean(object, attr)
        if object.send(attr)
          "Yes"
        else
          "No"
        end
      end

      def csv_format_file(object, attr)
        file = object.send(attr)
        file.name if file.present?
      end

      def csv_format_inline(object, attr)
        object.send(attr).map(&:to_s).join("|")
      end

      alias_method :csv_format_multiselect_association, :csv_format_inline
      alias_method :csv_format_array, :csv_format_inline

      def csv_format_date(object, attr)
        object.send(attr).try(:strftime, "%d/%m/%y")
      end

      def csv_format_datetime(object, attr)
        object.send(attr).try(:strftime, "%d/%m/%y %H:%M:%S")
      end

      def csv_format_time(object, attr)
        object.send(attr).try(:strftime, "%H:%M:%S")
      end
    end
  end
end
