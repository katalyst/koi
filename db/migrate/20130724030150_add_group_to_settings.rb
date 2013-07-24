class AddGroupToSettings < ActiveRecord::Migration
  def change
    add_column :translations, :group, :string
  end
end
