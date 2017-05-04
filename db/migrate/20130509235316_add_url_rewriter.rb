class AddUrlRewriter < ActiveRecord::Migration[5.0]
  def change
    create_table :url_rewrites do |t|
      t.text    :from
      t.text    :to
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
