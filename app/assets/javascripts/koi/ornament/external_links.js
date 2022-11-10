/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, Orn, $) {

  "use strict";

  var query = [];

  // Add suffixes to query.
  $.each(Orn.externalLinkExtensions, function (i, v) {
    query.push("[href$='." + v + "']");
    query.push("[href$='." + v.toUpperCase() + "']");
  });

  // Add prefixes to query.
  $.each([ "http://", "https://" ], function (i, v) {
    query.push("[href^='" + v + "']");
  });

  $(document).on("ornament:refresh", function () {
    // Handle clicks.
    $(query.join(", ")).each(function(){
      if(!this.is("[data-same-window]")) {
        $(this).attr("target", "_blank");

        // Add noopener to external links programatically
        // https://mathiasbynens.github.io/rel-noopener/
        if (!this.is("[rel]")) {
          this.attr("rel", "noopener");
        }
      }
    });
  });

}(document, window, Ornament, jQuery));
