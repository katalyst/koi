# frozen_string_literal: true

class AddOTPSecretToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :admins, :otp_secret, :string
  end
end
