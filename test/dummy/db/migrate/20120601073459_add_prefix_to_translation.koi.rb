# This migration comes from koi (originally 20120601005318)
class AddPrefixToTranslation < ActiveRecord::Migration
  def up
    add_column   :translations, :prefix, :string
    remove_index :translations, :key
    add_index    :translations, [:prefix, :key], unique: true
  end

  def down
    remove_column :translations, :prefix
    remove_index  :translations, [:prefix, :key]
    add_index     :translations, :key, unique: true
  end
end
