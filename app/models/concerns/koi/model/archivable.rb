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
    #
    # Filtering:
    # Use the custom `:archivable` enum attribute in Admin::Collections to
    # filter on this property, e.g.
    #
    #     attribute :status, :archivable, default: :active
    #
    # Note: although it's theoretically possible to archive something in the
    # future, this module does not support queries using dates.
    module Archivable
      extend ActiveSupport::Concern

      included do
        scope :not_archived, -> { where(archived_at: nil) }
        scope :archived, -> { unscope(where: :archived_at).where.not(archived_at: nil) }
        scope :with_archived, -> { unscope(where: :archived_at) }

        scope :status, ->(status) do
          case status.to_s
          when "active"
            not_archived
          when "archived"
            archived
          else
            with_archived
          end
        end

        default_scope { not_archived }

        alias_method :archived?, :archived
      end

      # Returns true iff the record has been archived.
      def archived
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
