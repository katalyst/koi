# frozen_string_literal: true

class RemoveLegacyAuthColumnsFromAdmins < ActiveRecord::Migration[8.0]
  def change
    change_table :admins, bulk: true do |t|
      t.remove :current_sign_in_at, type: :datetime
      t.remove :current_sign_in_ip, type: :string
      t.remove :last_sign_in_at, type: :datetime
      t.remove :last_sign_in_ip, type: :string
      t.remove :last_sign_out_at, type: :datetime
    end
  end
end
