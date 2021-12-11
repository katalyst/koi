# frozen_string_literal: true

class UpdateIndexOnTranslations < ActiveRecord::Migration[4.2]
  def change
    add_index :translations, %i[prefix key]
  end
end
