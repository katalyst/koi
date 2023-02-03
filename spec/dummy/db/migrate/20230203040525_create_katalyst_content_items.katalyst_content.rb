# frozen_string_literal: true

# This migration comes from katalyst_content (originally 20220913003839)
class CreateKatalystContentItems < ActiveRecord::Migration[7.0]
  def change
    create_table :katalyst_content_items do |t|
      t.string :type
      t.belongs_to :container, polymorphic: true

      t.string :heading, null: false
      t.boolean :show_heading, null: false, default: true
      t.string :background, null: false
      t.boolean :visible, null: false, default: true

      t.timestamps
    end
  end
end
