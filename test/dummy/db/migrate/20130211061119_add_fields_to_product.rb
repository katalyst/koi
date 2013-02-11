class AddFieldsToProduct < ActiveRecord::Migration
  def change
    add_column :products, :short_description, :text
    add_column :products, :publish_date, :date
    add_column :products, :launch_date, :date
    add_column :products, :genre, :text
    add_column :products, :banner_uid, :string
    add_column :products, :banner_name, :string
    add_column :products, :manual_uid, :string
    add_column :products, :manual_name, :string
    add_column :products, :size, :string
    add_column :products, :countries, :text
    add_column :products, :colour, :string
    add_column :products, :active, :boolean, default: true
    add_column :products, :ordinal, :integer
  end
end
