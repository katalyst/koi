/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    var $dropdownAnchors = $("[data-dropdown-toggle]");

    var closeDropdown = function ($parent) {
      $parent.removeClass("open");
    };

    var closeOtherDropdowns = function ($parent) {
      var $otherParents = $("[data-dropdown-toggle]")
        .parent(".dropdown")
        .not($parent);
      closeDropdown($otherParents);
    };

    var openDropdown = function ($parent) {
      $parent.addClass("open");
      closeOtherDropdowns($parent);
    };

    var toggleDropdown = function ($parent) {
      if ($parent.hasClass("open")) {
        closeDropdown($parent);
      } else {
        openDropdown($parent);
      }
    };

    $dropdownAnchors.each(function () {
      var $anchor = $(this);
      var $parent = $anchor.parent(".dropdown");

      $anchor.off("click").on("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        toggleDropdown($parent);
      });

      $("html").on("click onfocus touch", function () {
        closeDropdown($parent);
      });
    });
  });
})(document, window, jQuery);
