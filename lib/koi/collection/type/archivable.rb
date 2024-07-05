# frozen_string_literal: true

module Koi
  module Collection
    module Type
      # Add support for `attribute :status, :archivable, default: :active` to
      # Koi collections to support filtering on Koi::Model::Archivable models.
      class Archivable < Katalyst::Tables::Collection::Type::Enum
        def initialize(scope: :status)
          super(multiple: false, scope:)
        end

        def type
          :archivable
        end

        def examples_for(scope, attribute)
          _, model, = model_and_column_for(scope, attribute)

          %i[active archived all].map do |key|
            example(key, describe_key(model, attribute, key))
          end
        end

        private

        def describe_key(model, attribute, key)
          description = I18n.t("koi.view.#{attribute.name}.#{key}", model: model.model_name.human)
          description += " (default)" if key.to_s.eql?(attribute.original_value.to_s)
          description
        end
      end
    end
  end
end
