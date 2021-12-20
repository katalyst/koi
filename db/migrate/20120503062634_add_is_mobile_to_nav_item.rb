# frozen_string_literal: true

class AddIsMobileToNavItem < ActiveRecord::Migration[4.2]
  def change
    add_column :nav_items, :is_mobile, :boolean, default: false
  end
end
