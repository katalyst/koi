# frozen_string_literal: true

class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.string   :title
      t.text     :description
      t.string   :slug

      t.timestamps
    end

    add_index :pages, :slug, unique: true
  end
end
