# frozen_string_literal: true

class AddLastSignOutAtToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :admins, :last_sign_out_at, :datetime
  end
end
