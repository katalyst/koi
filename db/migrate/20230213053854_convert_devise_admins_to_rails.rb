# frozen_string_literal: true

class ConvertDeviseAdminsToRails < ActiveRecord::Migration[7.0]
  def change
    rename_column :admins, :encrypted_password, :password_digest
  end
end
