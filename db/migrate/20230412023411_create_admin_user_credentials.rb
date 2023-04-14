# frozen_string_literal: true

class CreateAdminUserCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_credentials do |t|
      t.string "external_id", index: { unique: true }
      t.references :admin, null: false, foreign_key: true

      t.string "public_key"
      t.string "nickname"
      t.bigint "sign_count", default: 0, null: false

      t.timestamps
    end

    change_table :admins do |t|
      t.column :webauthn_id, :string
    end
  end
end
