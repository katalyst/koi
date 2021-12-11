# frozen_string_literal: true

class AddSlugToAssets < ActiveRecord::Migration[4.2]
  def change
    add_column :assets, :slug, :string
  end
end
