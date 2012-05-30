# This migration comes from koi (originally 20120516034644)
class CreateReport < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer  :visits
      t.integer  :unique_pageviews
      t.integer  :pageviews
      t.float    :pageviews_per_visit
      t.float    :avg_time_on_site
      t.float    :visit_bounce_rate
      t.integer  :new_visits
      t.integer  :organic_searches

      t.date     :start_date
      t.date     :end_date

      t.timestamps
    end
  end
end
