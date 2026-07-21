# frozen_string_literal: true

module Admin
  # A machine actor, assumable only via an identity member's grant — nothing
  # signs in as a role. Config declares roles (a role exists when a member's
  # scope names it); the row is the stable identity that grants and audit
  # records reference, materialized on first use and never deleted.
  class Role < ApplicationRecord
    self.table_name = :admin_roles

    validates :slug, presence: true

    has_many :device_authorizations,
             class_name:  "Admin::DeviceAuthorization",
             foreign_key: :admin_role_id,
             inverse_of:  :admin_role,
             dependent:   :destroy

    def self.materialize(slug)
      create_or_find_by!(slug:)
    end

    # Config is authoritative for grants: a row whose slug no longer appears
    # in any member's scope is not assumable, but remains for attribution.
    def orphaned?
      Koi::Identity.role_slugs.exclude?(slug)
    end
  end
end
