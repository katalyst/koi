require 'garb'

class Report < ActiveRecord::Base
  extend Garb::Model

  metrics :visits,
          :unique_pageviews,
          :pageviews,
          :pageviews_per_visit,
          :avg_time_on_site,
          :visit_bounce_rate,
          :new_visits

  def self.profile
    return @profile if @profile
    Garb::Session.login(Translation.find_by_key('site.google_analytics.username').try(:value),
                        Translation.find_by_key('site.google_analytics.password').try(:value))
    @profile ||= Garb::Management::Profile.all.detect { |p|
                        p.web_property_id == Translation.find_by_key('site.google_analytics.profile_id').try(:value) }
  end

  def self.analytics(options={})
    options = { start_date: Date.today - 1.month,
                end_date: Date.today }.merge options

    result = find_by_start_date_and_end_date(options[:start_date], options[:end_date])

    return result if result

    analytics = results(profile, options)

    create(analytics.first.marshal_dump.merge(options))
  end
end
