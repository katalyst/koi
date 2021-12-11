class UpdateIndexOnTranslations < ActiveRecord::Migration[4.2]
  def change
    add_index :translations, [:prefix, :key]
  end
end
