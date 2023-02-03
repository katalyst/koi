# frozen_string_literal: true

# This migration comes from katalyst_navigation (originally 20220908044500)
class AddDepthLimitToMenus < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_navigation_menus, :depth, :integer
  end
end
