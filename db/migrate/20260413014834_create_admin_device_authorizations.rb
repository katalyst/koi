# frozen_string_literal: true

class CreateAdminDeviceAuthorizations < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_device_authorizations do |t|
      t.string :device_code_digest, null: false, index: { unique: true }
      t.string :user_code, null: false, index: { unique: true }
      t.string :status, null: false, default: "pending"
      t.datetime :request_expires_at, null: false
      t.datetime :approved_at
      t.datetime :consumed_at
      t.datetime :token_expires_at
      t.references :admin_user, null: true, foreign_key: { to_table: :admins }
      t.string :requested_ip
      t.string :user_agent

      t.timestamps
    end
  end
end
