# frozen_string_literal: true

module Koi
  module SummaryList
    class AttachmentComponent < Base
      def initialize(model, attribute, variant: :thumb, **attributes)
        super(model, attribute, **attributes)

        @variant = variant
      end

      def attribute_value
        if raw_value.try(:representable?)
          image_tag(@variant.nil? ? raw_value : raw_value.variant(@variant))
        elsif raw_value.try(:attached?)
          link_to raw_value.blob.filename, rails_blob_path(raw_value, disposition: :attachment)
        end
      end
    end
  end
end
