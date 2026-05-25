# frozen_string_literal: true

class CleanUpAdminUserTimestamps < ActiveRecord::Migration[8.1]
  def change
    # remove 'last sign in' tracking columns, database sessions make these redundant
    remove_column :admins, :last_sign_in_at, :datetime, precision: nil
    remove_column :admins, :last_sign_in_ip, :string

    # rename 'current sign in' columns to 'last sign in', as all active sessions are invalidated by this release
    rename_column :admins, :current_sign_in_at, :last_sign_in_at
    rename_column :admins, :current_sign_in_ip, :last_sign_in_ip

    # add counter caches for admin visibility
    add_column :admins, :device_authorizations_count, :integer, default: 0, null: false
    add_column :admins, :sessions_count, :integer, default: 0, null: false

    up_only do
      change_column :admins, :created_at, :datetime, precision: 6
      change_column :admins, :updated_at, :datetime, precision: 6
      change_column :admins, :last_sign_in_at, :datetime, precision: 6
    end
  end
end
