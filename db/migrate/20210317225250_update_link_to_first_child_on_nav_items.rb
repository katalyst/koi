# frozen_string_literal: true

class UpdateLinkToFirstChildOnNavItems < ActiveRecord::Migration[4.2]
  def change
    # update link_to_first_child, non null default false
    change_column :nav_items, :link_to_first_child, :boolean, null: false, default: false
  end
end
