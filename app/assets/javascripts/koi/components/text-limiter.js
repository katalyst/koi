/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

// http://www.scriptiny.com/2012/09/jquery-input-textarea-limiter/
(function ($) {
  $.fn.extend({
    limiter: function (limit, elem) {
      $(this).on("keyup focus", function () {
        setCount(this, elem);
      });
      function setCount(src, elem) {
        var chars = src.value.length;
        if (chars > limit) {
          src.value = src.value.substr(0, limit);
          chars = limit;
        }
        elem.html(limit - chars + " left");
      }
      setCount($(this)[0], elem);
    },
  });
})(jQuery);

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    $("[data-limiter]").each(function (i, elem) {
      // only apply if the element is found
      var $elem = $(elem);
      var limit = $elem.data("limiter");
      if ($elem.length > 0) {
        var $charCountContainer = $(
          "<span class='form--field-with-count--counter' />"
        );
        var $charCountHeading = $(
          "<div class='form--field-with-count--heading'>" +
            limit +
            " character limit</div>"
        );
        $charCountHeading.append($charCountContainer);

        $elem
          .wrap("<div class='form--field-with-count' />")
          .before($charCountHeading);
        $elem.limiter(limit, $charCountContainer);
      }
    });
  });
})(document, window, jQuery);
