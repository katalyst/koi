# frozen_string_literal: true

class AddAdminRoleToAdminDeviceAuthorizations < ActiveRecord::Migration[8.0]
  def change
    add_reference :admin_device_authorizations, :admin_role, null: true, foreign_key: true

    add_check_constraint :admin_device_authorizations,
                         "admin_user_id IS NULL OR admin_role_id IS NULL",
                         name: "admin_device_authorizations_single_actor"

    # allow device authorizations to be created without the request/approval flow
    change_column_null :admin_device_authorizations, :device_code_digest, true
    change_column_null :admin_device_authorizations, :request_expires_at, true
    change_column_null :admin_device_authorizations, :user_code, true

    # regenerate the unique indexes to ignore nulls
    remove_index :admin_device_authorizations, :device_code_digest, unique: true
    add_index :admin_device_authorizations, :device_code_digest,
              unique: true, where: "device_code_digest IS NOT NULL"

    remove_index :admin_device_authorizations, :user_code, unique: true
    add_index :admin_device_authorizations, :user_code,
              unique: true, where: "user_code IS NOT NULL"
  end
end
