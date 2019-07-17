class RenameComposableDataToBodyForPages < ActiveRecord::Migration[5.2]
  def change
    rename_column :pages, :composable_data, :body
  end
end
