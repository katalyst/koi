# frozen_string_literal: true

class DropTranslations < ActiveRecord::Migration[7.0]
  def up
    drop_table :translations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
