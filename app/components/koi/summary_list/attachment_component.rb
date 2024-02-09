# frozen_string_literal: true

module Koi
  module SummaryList
    class AttachmentComponent < Base
      def attribute_value
        link_to raw_value.blob.filename, rails_blob_path(raw_value, disposition: :attachment)
      end
    end
  end
end
