# frozen_string_literal: true

class CreateAdminSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :admin_sessions do |t|
      t.references :admin, null: false, foreign_key: { to_table: :admins }
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
