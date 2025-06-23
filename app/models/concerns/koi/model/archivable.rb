# frozen_string_literal: true

module Koi
  module Model
    # Add support for archiving using an `:archived_at` column. Adds scopes for
    # including/excluding collection elements based on whether they have an
    # archived_at date set or not.
    #
    # Usage:
    # Include this module in your model and add the `archived_at` column via a
    # migration.
    #
    # Examples:
    #     Model.all # default scope, excludes archived
    #     Model.archived # only returns archived records
    #     Model.with_archived # returns all records
    module Archivable
      extend ActiveSupport::Concern

      included do
        scope :not_archived, -> { where(archived_at: nil) }
        scope :archived, -> { unscope(where: :archived_at).where.not(archived_at: nil) }
        scope :with_archived, -> { unscope(where: :archived_at) }

        default_scope { not_archived }

        alias_method :archived, :archived?
      end

      # @return true if the record has been archived.
      def archived?
        archived_at.present?
      end

      # Update archived status based on given boolean value.
      def archived=(archived)
        if ActiveRecord::Type::Boolean.new.cast(archived)
          archive
        else
          restore
        end
      end

      # Mark a record as archived. It will no longer appear in default queries.
      def archive
        self.archived_at = Time.current
      end

      # Archive a record immediately, without validation.
      def archive!
        archive
        save!(validate: false) if persisted?
        self
      end

      # Mark a record as no longer archived. It will appear in default queries.
      def restore
        self.archived_at = nil
      end

      # Restore a record immediately, without validation.
      def restore!
        restore
        save!(validate: false) if persisted?
        self
      end
    end
  end
end
