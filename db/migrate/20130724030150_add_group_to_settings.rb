# frozen_string_literal: true

class AddGroupToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :translations, :group, :string
  end
end
