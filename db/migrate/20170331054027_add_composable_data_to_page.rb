class AddComposableDataToPage < ActiveRecord::Migration
  def change
    add_column :pages, :composable_data, :jsonb
  end
end
