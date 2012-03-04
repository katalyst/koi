class Exits < ActiveRecord::Base
  extend Garb::Model

  set_instance_klass self

  metrics :exits, :pageviews, :unique_pageviews
  dimensions :page_path

  default_scope order("unique_pageviews DESC")

  def self.profile
    return @@profile if defined?(@@profile) && @@profile
    Garb::Session.login(Translation.find_by_key('site.google_analytics.username').value,
                        Translation.find_by_key('site.google_analytics.password').value)
    @@profile ||= Garb::Management::Profile.all.detect { |p|
                        p.web_property_id = Translation.find_by_key('site.google_analytics.profile_id').value }
  end

  def self.analytics(reset=nil)
    if reset || Exits.count.eql?(0)
      @result = Exits.results(profile,
                       limit: 10,
                       offset: 1,
                       start_date: Date.today - 6.months,
                       end_date: Date.today,
                       sort: :unique_pageviews.desc)
      Exits.destroy_all
      @result.each do |result|
        exits = Exits.find_or_create_by_page_path(result.page_path)
        exits.update_attributes(result.attributes)
      end
    end
    Exits.all
  end

  def self.browsers
    result = Garb::Report.new(profile,
                       start_date: (Date.today - 6.months),
                       end_date: Date.today,
                       metrics: [:pageviews],
                       dimensions: [:browser]).results
    sum = result.sum { |r| r.pageviews.to_i }
    result.collect { |r| [r.browser, ((r.pageviews.to_f / sum) * 100).round(2)] if ((r.pageviews.to_f / sum) * 100).round(2) > 1 }.compact
  end

  def self.keywords
    result = Garb::Report.new(profile,
                       limit: 5,
                       offset: 1,
                       start_date: (Date.today - 6.months),
                       end_date: Date.today,
                       metrics: [:pageviews],
                       dimensions: [:keyword],
                       sort: :pageviews.desc
                       ).results
    sum = result.sum { |r| r.pageviews.to_i }
    result.collect { |r| [r.keyword, ((r.pageviews.to_f / sum) * 100).round(2)] if ((r.pageviews.to_f / sum) * 100).round(2) > 1 }.compact
  end

  def self.continents
    Garb::Report.new(profile,
                     start_date: (Date.today - 6.months),
                     end_date: Date.today,
                     metrics: [:pageviews],
                     dimensions: [:continent],
                     sort: :pageviews.desc
                     ).results
  end
end
