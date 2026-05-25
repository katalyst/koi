# frozen_string_literal: true

class CreateAdminSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_sessions do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
