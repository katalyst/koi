# frozen_string_literal: true

class CreateAdminRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_roles do |t|
      t.string :slug, null: false, index: { unique: true }
      t.datetime :tokens_revoked_at

      t.timestamps
    end
  end
end
