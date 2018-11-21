# This migration comes from koi (originally 20130724030150)
class AddGroupToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :translations, :group, :string
  end
end
