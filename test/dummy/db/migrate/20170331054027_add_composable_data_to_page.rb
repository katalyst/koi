class AddComposableDataToPage < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :composable_data, :jsonb
  end
end
