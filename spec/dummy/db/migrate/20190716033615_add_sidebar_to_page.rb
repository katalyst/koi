class AddSidebarToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :sidebar, :jsonb
  end
end
