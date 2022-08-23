/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";
  
  $(document).on("pjax:end", "*", function () {
    $(document).trigger("ornament:refresh");
  });

  $(document).on("turbo:load", function () {
    $(document).trigger("ornament:refresh");
  });

}(document, window, jQuery));
