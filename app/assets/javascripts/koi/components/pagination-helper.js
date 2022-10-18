/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {
  "use strict";

  $(function () {
    // only do all of this if there's pagination on the page.
    var $pagination = $(".pagination");
    if ($pagination.length > 0) {
      var $current = $pagination.find(".page.current");

      var paginationIsFirstPage = function () {
        if ($pagination.find(".page").first().hasClass("current")) {
          return true;
        } else {
          return false;
        }
      };
      var paginationIsLastPage = function () {
        if ($pagination.find(".page").last().hasClass("current")) {
          return true;
        } else {
          return false;
        }
      };
      var paginationShowHide = function () {
        if (paginationIsLastPage() || paginationIsFirstPage()) {
          return false;
        }
        var windowWidth = Ornament.windowWidth();
        if (windowWidth <= 430) {
          $current.prev(".page").prev(".page").hide();
          $current.next(".page").next(".page").hide();
        } else {
          $current.prev(".page").prev(".page").show();
          $current.next(".page").next(".page").show();
        }
      };

      $(window).on("resize", function () {
        paginationShowHide();
      });

      paginationShowHide();
    }
  });
})(document, window, jQuery);
