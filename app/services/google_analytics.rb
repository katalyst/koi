# Analytics for Koi
require 'google/apis/analyticsreporting_v4'
require 'googleauth'

include Google::Apis::AnalyticsreportingV4
include Google::Auth

class GoogleAnalytics

  def self.view_id
    "ga:126984837"
  end

  def self.get_access_token
    credential_file = Rails.root.join("config/analytics_client_secrets.json")
    if credential_file.exist?
      creds = ServiceAccountCredentials.make_creds({json_key_io: File.open(credential_file), scope: 'https://www.googleapis.com/auth/analytics.readonly'})
      creds.fetch_access_token["access_token"]
    else
      false
    end
  end

  def self.chart_loader
    %Q(
      <div class="card--body--section card--body--section__loading">
        #{icon("spinner")}
      </div>
    ).html_safe
  end

  def self.chart(heading, type, api_queries)
    scopable = api_queries.collect { |q| q[:settings][:scopable] === "false" }.reject { |q| q == true }
    datasets = api_queries.map { |q| q[:settings] }.to_json
    api_queries = api_queries.collect { |q| q.reject! { |k| k == :settings } }.to_json
    %Q(
      <div class='report'>
        <h2 class="heading-three">#{heading}</h2>
        <div id="#{heading.parameterize}">#{self.chart_loader}</div>
        <script>
          Analytics.charts.push({
            embedApi: {
              scopable: #{scopable.present?},
              query: {
                'ids': Analytics.view_id,
                'start-date': Analytics.defaultDateRange['start-date'],
                'end-date': Analytics.defaultDateRange['end-date']
              },
              queries: #{api_queries},
              chart: {
                'container': '#{heading.parameterize}',
                'type': "#{type}",
                'datasets': #{datasets}
              }
            }
          })
        </script>
      </div>
    ).html_safe
  end

  def self.setup
    %Q(
      <style>
        /* Options */
        .analytics-options {
          display: flex;
          flex-direction: row;
          margin: -10px;
        }
        .analytics-options > div {
          padding: 10px;
        }
        .analytics-options label {
          display: inline-block;
          margin-bottom: 5px;
        }
        .DateRangeSelector {
          display: flex;
          margin: -10px;
          flex-direction: row;
        }
        .DateRangeSelector-item {
          padding: 10px;
        }
      </style>
      <script>
      (function(w,d,s,g,js,fs){
        g=w.gapi||(w.gapi={});g.analytics={q:[],ready:function(f){this.q.push(f);}};
        js=d.createElement(s);fs=d.getElementsByTagName(s)[0];
        js.src='https://apis.google.com/js/platform.js';
        fs.parentNode.insertBefore(js,fs);js.onload=function(){g.load('analytics');};
      }(window,document,'script'));
      </script>
      <script src="/assets/koi/moment.js"></script>
      <script src="/assets/koi/html-entities.js"></script>
      <script src="/assets/koi/analytics-date-range-selector.js"></script>
      <script src="/assets/koi/chart.js"></script>
      <script src="/assets/koi/koi-analytics.js"></script>
      <script>
        KoiGoogleAnalytics = {}
        KoiGoogleAnalytics.access_token = "#{GoogleAnalytics.get_access_token}";
        KoiGoogleAnalytics.view_id = "#{GoogleAnalytics.view_id}";
        KoiGoogleAnalytics.defaultDateRange = {
          'start-date': '#{(Time.zone.now - 12.weeks).strftime("%Y-%m-%d")}',
          'end-date': 'yesterday'
        };
        KoiGoogleAnalytics.charts = [];
      </script>
    ).html_safe
  end

end