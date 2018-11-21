class CreateSuperHeros < ActiveRecord::Migration[4.2]
  def change
    create_table :super_heros do |t|
      t.string  :name
      t.text    :description
      t.date    :published_at
      t.string  :gender
      t.boolean :is_alive, default: true
      t.string  :url
      t.string  :telephone
      t.string  :image_uid
      t.string  :image_name
      t.string  :file_uid
      t.string  :file_name
      t.integer :value
      t.string  :powers
      t.string  :slug
      t.integer :ordinal

      t.timestamps
    end

    add_index :super_heros, :slug, :unique => true
  end
end
