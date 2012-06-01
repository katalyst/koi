# This migration comes from koi (originally 20120601005318)
class AddPrefixToTranslation < ActiveRecord::Migration
  def change
    add_column :translations, :prefix, :string
  end
end
