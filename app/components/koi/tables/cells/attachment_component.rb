# frozen_string_literal: true

module Koi
  module Tables
    module Cells
      # Shows an attachment
      #
      # The value is expected to be an ActiveStorage attachment
      #
      # If it is representable, shows as a image tag using the specified variant.
      #
      # Otherwise shows as a link to download.
      class AttachmentComponent < Katalyst::Tables::CellComponent
        def initialize(variant:, **)
          super(**)

          @variant = variant
        end

        def rendered_value
          representation
        end

        def representation
          if value.try(:variable?) && named_variant.present?
            image_tag(value.variant(@variant))
          elsif value.try(:attached?)
            filename.to_s
          else
            ""
          end
        end

        def filename
          value.blob.filename
        end

        # Utility for accessing the path Rails provides for retrieving the
        # attachment for use in cells. Example:
        #    <% row.attachment :file do |cell| %>
        #       <%= link_to "Download", cell.internal_path %>
        #    <% end %>
        def internal_path
          rails_blob_path(value, disposition: :attachment) if value.try(:attached?)
        end

        private

        def default_html_attributes
          { class: "type-attachment" }
        end

        # Find the reflective variant by name (i.e. :thumb by default)
        def named_variant
          record.attachment_reflections[@column.to_s].named_variants[@variant.to_sym]
        end
      end
    end
  end
end
