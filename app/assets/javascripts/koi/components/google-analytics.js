(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function(){

    var Analytics = Ornament.C.GoogleAnalytics = {};

    // Get settings from window if available
    if(window.KoiGoogleAnalytics) {
      _.merge(Analytics, window.KoiGoogleAnalytics);
    }

    // =========================================================================
    // Selectors
    // =========================================================================

    Analytics.selectors = {
      dateRangeTool: "[data-dashboard-date-range]"
    }

    // =========================================================================
    // Authentication 
    // =========================================================================

    Analytics.authenticate = function(){
      gapi.analytics.auth.authorize({
        'serverAuth': {
          'access_token': Analytics.access_token
        }
      });
    }

    // =========================================================================
    // Translations
    // =========================================================================

    // =========================================================================
    // Error states 
    // =========================================================================

    // =========================================================================
    // Generate queries from list of queries 
    // =========================================================================

    // =========================================================================
    // Update charts with new data 
    // =========================================================================

    // =========================================================================
    // Initialisation
    // =========================================================================

    // gapi.analytics.ready(function(){

    //   // Do nothing if access token is missing
    //   if(!Analytics.access_token) {
    //     return false;
    //     console.warn("Not rendering analytics data, missing access token");
    //   }

    //   // Authenticate against Google Analytics 
    //   Analytics.authenticate();

    //   // Set date range selector
    //   var dateRangeSelector = Analytics.dateRangeTool = new gap.analytics.ext.DateRangeSelector({
    //     contianer: 'date-container'
    //   });

    // });


  });

}(document, window, jQuery));