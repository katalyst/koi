# This migration comes from koi (originally 20130724030150)
class AddGroupToSettings < ActiveRecord::Migration
  def change
    add_column :translations, :group, :string
  end
end
