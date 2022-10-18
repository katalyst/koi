/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

//= require koi/stickykit.js

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    $("[data-sticky]").each(function () {
      var $element = $(this);
      var options = {
        offset_top: $element.attr("data-sticky-offset") || 65,
        sticky_class: $element.attr("data-sticky-class") || "is_stuck",
      };
      $element.stick_in_parent(options);
    });
  });
})(document, window, jQuery);
