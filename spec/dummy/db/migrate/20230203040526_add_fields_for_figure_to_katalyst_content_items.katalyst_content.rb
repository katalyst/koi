# frozen_string_literal: true

# This migration comes from katalyst_content (originally 20220926061535)
class AddFieldsForFigureToKatalystContentItems < ActiveRecord::Migration[7.0]
  def change
    add_column :katalyst_content_items, :caption, :string
  end
end
