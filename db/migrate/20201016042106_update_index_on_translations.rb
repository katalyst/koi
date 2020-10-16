class UpdateIndexOnTranslations < ActiveRecord::Migration
  def change
    add_index :translations, [:prefix, :key]
  end
end
