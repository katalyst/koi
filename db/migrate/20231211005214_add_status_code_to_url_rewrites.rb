# frozen_string_literal: true

class AddStatusCodeToUrlRewrites < ActiveRecord::Migration[7.1]
  def change
    add_column :url_rewrites, :status_code, :integer, null: false, default: 303
  end
end
