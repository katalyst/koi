# frozen_string_literal: true

module Koi
  module Collection
    module Type
      # Add support for `attribute :status, :archivable, default: :active` to
      # Koi collections to support filtering on Koi::Model::Archivable models.
      class Archivable < Katalyst::Tables::Collection::Type::Enum
        def initialize
          super(multiple: false, scope: :status)
        end

        def type
          :archivable
        end

        def examples_for(...)
          %i[active archived all]
        end
      end
    end
  end
end
