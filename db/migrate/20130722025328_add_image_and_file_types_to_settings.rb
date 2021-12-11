class AddImageAndFileTypesToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :translations, :file_uid,         :string
    add_column :translations, :file_name,        :string
    add_column :translations, :serialized_value, :text
  end
end
