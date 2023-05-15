# frozen_string_literal: true

# This migration comes from katalyst_content (originally 20230515151440)
class ChangeKatalystContentItemsShowHeadingColumn < ActiveRecord::Migration[7.0]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    add_column :katalyst_content_items, :heading_style, :integer, null: false, default: 0
    Katalyst::Content::Item.where(show_heading: true).update_all(heading_style: 1)
    remove_column :katalyst_content_items, :show_heading, :boolean
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
