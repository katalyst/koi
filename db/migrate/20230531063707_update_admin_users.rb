class UpdateAdminUsers < ActiveRecord::Migration[7.0]
  class Admin < ActiveRecord::Base; end

  def up
    add_column :admins, :name, :string

    Admin.all.each do |admin|
      admin.name = "#{admin.first_name} #{admin.last_name}"
      admin.save!
    end

    remove_column :admins, :first_name, :string
    remove_column :admins, :last_name, :string
    remove_column :admins, :reset_password_token, :string, index: { unique: true }
    remove_column :admins, :reset_password_sent_at, :datetime
    remove_column :admins, :remember_created_at, :datetime
    remove_column :admins, :locked_at, :datetime
    remove_column :admins, :role, :string
  end

  def down
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :reset_password_token, :string, index: { unique: true }
    add_column :admins, :reset_password_sent_at, :datetime
    add_column :admins, :remember_created_at, :datetime
    add_column :admins, :locked_at, :datetime
    add_column :admins, :role, :string

    Admin.all.each do |admin|
      admin.first_name, admin.last_name = admin.name.split(' ', 2)
      admin.save!
    end

    remove_column :admins, :name, :string
  end
end
