class AddTypeToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :type, :string
  end

  def self.down
    remove_column :pages, :type, :string
  end
end
