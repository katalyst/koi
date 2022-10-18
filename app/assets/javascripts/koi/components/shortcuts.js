/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    // Toggle the menu open/close
    keyboardJS.bind("alt + m", function (e) {
      mobileNav.toggleMenu();
      if (mobileNav.filterElement) {
        mobileNav.filterElement.blur();
        mobileNav.filterElement.val("");
        mobileNav.clearFilter();
      }
    });

    // Close the menu or close a lightbox
    keyboardJS.bind("esc", function (e) {
      if (mobileNav.isOpen()) {
        mobileNav.closeMenu();
      }
      $.magnificPopup.close();
    });
  });
})(document, window, jQuery);
