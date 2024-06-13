# frozen_string_literal: true

class AddUrlRewriter < ActiveRecord::Migration[4.2]
  def change
    create_table :url_rewrites do |t|
      t.text    :from
      t.text    :to
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
