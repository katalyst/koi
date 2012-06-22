class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string  :heading
      t.text    :description
      t.integer :attribute_ordinal
      t.string  :attribute_name
      t.integer :attributable_id
      t.string  :attributable_type
      t.timestamps
    end
  end
end
