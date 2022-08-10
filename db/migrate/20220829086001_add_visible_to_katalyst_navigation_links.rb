# frozen_string_literal: true

class AddVisibleToKatalystNavigationLinks < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_navigation_links, :visible, :boolean, default: true
  end
end
