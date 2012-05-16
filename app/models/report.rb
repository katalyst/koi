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

  Humanize = {
    visits: "Visits",
    unique_pageviews: "Unique page views",
    pageviews: "Page views",
    pageviews_per_visit: "Page views per visit",
    avg_time_on_site: "Avg time on site",
    visit_bounce_rate: "Bounce rate (%)",
    new_visits: "New visits"

  }

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

  def previous_month
    @previous_month ||= self.class.analytics(start_date: start_date - 1.month, end_date: start_date)
  end

  def method_missing(method_sym, *arguments, &block)
    if method_sym.to_s =~ /^(.*)_diff$/ && self.class.metrics.elements.include?($1.to_sym)
      change_from_last_month(read_attribute($1.to_sym), previous_month[$1.to_sym])
    elsif method_sym.to_s =~ /^(.*)_last_month$/ && self.class.metrics.elements.include?($1.to_sym)
      previous_month[$1.to_sym]
    else
      super
    end
  end

  private

  def change_from_last_month(value_now, value_last_month)
    ((value_now - value_last_month) / value_now.to_f * 100).round(1)
  end
end
