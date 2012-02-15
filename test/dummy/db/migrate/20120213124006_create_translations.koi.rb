# This migration comes from koi (originally 20120116011040)
class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
      t.string  :locale, default: "en"
      t.string  :label
      t.string  :key
      t.text    :value
      t.text    :interpolations
      t.string  :role
      t.string  :field_type, :default => "string"
      t.string  :hint
      t.boolean :is_proc, :default => false
      t.boolean :is_required, :default => false

      t.timestamps
    end

    add_index :translations, :key, :unique => true
  end
end
