# frozen_string_literal: true

class AddShortDescriptionToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :short_description, :string
  end
end
