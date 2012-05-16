# This migration comes from koi (originally 20120516034644)
class CreateReport < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.decimal :visits, precision: 8, scale: 2
      t.decimal :unique_pageviews, precision: 8, scale: 2
      t.decimal :pageviews, precision: 8, scale: 2
      t.decimal :pageviews_per_visit, precision: 8, scale: 2
      t.decimal :avg_time_on_site, precision: 8, scale: 2
      t.decimal :visit_bounce_rate, precision: 8, scale: 2
      t.decimal :new_visits, precision: 8, scale: 2

      t.date    :start_date
      t.date    :end_date

      t.timestamps
    end
  end
end
