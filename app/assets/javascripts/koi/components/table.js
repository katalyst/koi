/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    var $tableContainers = $(".table-container");

    var showHideShadows = function ($tableContainer) {
      var scrollLeft = $tableContainer.scrollLeft();
      var maxScroll =
        $tableContainer.find("table").outerWidth() -
        $tableContainer.outerWidth();
      var showLeftShadow = false;
      var showRightShadow = false;
      var $leftShadow = $tableContainer
        .parent()
        .find("[data-table-container-shadow-left]");
      var $rightShadow = $tableContainer
        .parent()
        .find("[data-table-container-shadow-right]");

      if (scrollLeft != 0) {
        showLeftShadow = true;
      }

      if (scrollLeft < maxScroll) {
        showRightShadow = true;
      }

      if (showLeftShadow) {
        $leftShadow.show();
      } else {
        $leftShadow.hide();
      }

      if (showRightShadow) {
        $rightShadow.show();
      } else {
        $rightShadow.hide();
      }
    };

    $tableContainers.each(function () {
      var $tableContainer = $(this);

      // Scaffold up our shadows
      var $container = $("<div class='table-container--outer' />");
      $container.append(
        "<div class='table-container--shadow table-container--shadow__left' data-table-container-shadow-left />"
      );
      $container.append(
        "<div class='table-container--shadow table-container--shadow__right' data-table-container-shadow-right />"
      );
      $tableContainer.before($container).appendTo($container);

      // On scroll
      $tableContainer.on("scroll", function () {
        showHideShadows($tableContainer);
      });

      $(window).on("resize", function () {
        showHideShadows($tableContainer);
      });

      $(document).on("ornament:tab-change", function () {
        showHideShadows($tableContainer);
      });

      $(document).on("ornament:table-shadows", function () {
        showHideShadows($tableContainer);
      });

      showHideShadows($tableContainer);
    });
  });
})(document, window, jQuery);
