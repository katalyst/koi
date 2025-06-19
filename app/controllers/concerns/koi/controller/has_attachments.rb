# frozen_string_literal: true

module Koi
  module Controller
    module HasAttachments
      extend ActiveSupport::Concern

      # Store attachments in the given object so that they can be preserved for
      # the next form submission.
      #
      # Example:
      #     def create
      #       @document = Document.new(document_params)
      #       if @document.save
      #         redirect_to [:admin, @document], status: :see_other
      #       else
      #         save_attachments!(@document)
      #         render :new, status: :unprocessable_content
      #       end
      #     end
      #
      # @param resource [ActiveRecord::Base] The object being edited
      def save_attachments!(resource)
        resource.attachment_changes.each_value do |change|
          case change
          when ActiveStorage::Attached::Changes::CreateOne
            change.upload
            change.blob.save!
          when ActiveStorage::Attached::Changes::CreateMany
            change.upload
            change.blobs.each(&:save!)
          end
        end
      end
    end
  end
end
