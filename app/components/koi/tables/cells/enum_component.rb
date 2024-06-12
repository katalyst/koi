# frozen_string_literal: true

module Koi
  module Tables
    module Cells
      # Displays an enum value using data inferred from the model.
      class EnumComponent < Katalyst::Tables::CellComponent
        def rendered_value
          if (value = self.value).present?
            label = t(i18n_enum_label_key(value), default: value)
            tag.span(label, data: { enum: column, value: })
          end
        end

        private

        def default_html_attributes
          { class: "type-enum" }
        end

        def i18n_enum_label_key(value)
          "active_record.attributes.#{collection.model_name.i18n_key}/#{column}.#{value}"
        end
      end
    end
  end
end
