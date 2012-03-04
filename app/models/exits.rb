class Exits < ActiveRecord::Base
  extend Garb::Model

  set_instance_klass self

  metrics :exits, :pageviews, :unique_pageviews
  dimensions :page_path

  default_scope order("unique_pageviews DESC")

  def self.profile
    Garb::Session.login(Translation.find_by_key('site.google_analytics.username').value,
                        Translation.find_by_key('site.google_analytics.password').value)
    Garb::Management::Profile.all.detect { |p|
                        p.web_property_id = Translation.find_by_key('site.google_analytics.profile_id').value }
  end

  def self.analytics(reset=nil)
    if reset || Exits.count.eql?(0)
      @result = Exits.results(profile,
                       :limit => 10,
                       :offset => 1,
                       :start_date => (Date.today - 6.months),
                       :end_date => Date.today,
                       :filters => {:unique_pageviews.gte => 200},
                       :sort => :unique_pageviews)
      Exits.destroy_all
      @result.each do |result|
        exits = Exits.find_or_create_by_page_path(result.page_path)
        exits.update_attributes(result.attributes)
      end
    end
    Exits.all
  end
end
