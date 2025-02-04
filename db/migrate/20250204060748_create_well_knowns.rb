# frozen_string_literal: true

class CreateWellKnowns < ActiveRecord::Migration[8.0]
  def change
    create_table :well_knowns do |t|
      t.string :name, index: { unique: true }
      t.string :purpose
      t.string :content_type
      t.string :content

      t.timestamps
    end
  end
end
