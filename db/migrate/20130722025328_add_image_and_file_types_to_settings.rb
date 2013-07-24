class AddImageAndFileTypesToSettings < ActiveRecord::Migration
  def change
    add_column :translations, :file_uid,         :string
    add_column :translations, :file_name,        :string
    add_column :translations, :serialized_value, :text
  end
end
