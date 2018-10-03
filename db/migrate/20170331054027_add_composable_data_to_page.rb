class AddComposableDataToPage < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :composable_data, :jsonb
  end
end
