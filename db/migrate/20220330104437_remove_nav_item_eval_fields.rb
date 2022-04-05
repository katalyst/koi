# frozen_string_literal: true

class RemoveNavItemEvalFields < ActiveRecord::Migration[7.0]
  def change
    remove_column :nav_items, :if, :text
    remove_column :nav_items, :unless, :text
    remove_column :nav_items, :highlights_on, :text
    remove_column :nav_items, :content_block, :text
  end
end
