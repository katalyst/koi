# frozen_string_literal: true

class MakeRelatedRecordsTimestampNotRequired < ActiveRecord::Migration[4.2]
  def up
    change_column(:related_products, :created_at, :datetime, null: true)
    change_column(:related_products, :updated_at, :datetime, null: true)
  end

  def down
    change_column(:related_products, :created_at, :datetime, null: false)
    change_column(:related_products, :updated_at, :datetime, null: false)
  end
end
