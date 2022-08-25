class RemoveCssFromNavigationLinks < ActiveRecord::Migration[7.0]
  def change
    remove_column :navigation_links, :css
  end
end
