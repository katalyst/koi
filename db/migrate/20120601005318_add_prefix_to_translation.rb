# frozen_string_literal: true

class AddPrefixToTranslation < ActiveRecord::Migration[4.2]
  def up
    add_column   :translations, :prefix, :string
    remove_index :translations, :key
    add_index    :translations, %i[locale prefix key], unique: true
  end

  def down
    remove_column :translations, :prefix
    remove_index  :translations, %i[locale prefix key]
    add_index     :translations, :key, unique: true
  end
end
