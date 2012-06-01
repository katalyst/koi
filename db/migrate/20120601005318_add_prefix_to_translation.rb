class AddPrefixToTranslation < ActiveRecord::Migration
  def change
    add_column :translations, :prefix, :string
  end
end
