# frozen_string_literal: true

class AddArchivedToAdminUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :admins, :archived_at, :datetime
  end
end
