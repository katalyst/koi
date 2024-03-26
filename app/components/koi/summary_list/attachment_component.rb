# frozen_string_literal: true

module Koi
  module SummaryList
    class AttachmentComponent < Base
      def initialize(model, attribute, variant: :thumb, **attributes)
        super(model, attribute, **attributes)

        @variant = variant
      end

      def attribute_value
        representation
      end

      def representation
        if raw_value.try(:variable?) && named_variant.present?
          image_tag(raw_value.variant(@variant))
        elsif raw_value.try(:attached?)
          filename.to_s
        else
          ""
        end
      end

      def filename
        raw_value.blob.filename
      end

      # Utility for accessing the path Rails provides for retrieving the
      # attachment for use in cells. Example:
      #    <% row.attachment :file do |cell| %>
      #       <%= link_to "Download", cell.internal_path %>
      #    <% end %>
      def internal_path
        rails_blob_path(raw_value, disposition: :attachment)
      end

      private

      # Find the reflective variant by name (i.e. :thumb by default)
      def named_variant
        @model.attachment_reflections[@attribute.to_s].named_variants[@variant.to_sym]
      end
    end
  end
end
