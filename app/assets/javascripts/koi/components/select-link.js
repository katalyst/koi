/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    var SelectLinks = (Ornament.C.SelectLinks = {
      markAsActiveForUrl: function ($select, url) {
        if ($select.find("option[value='" + url + "']").length > 0) {
          $select.val(url);
        }
      },

      bindSelectLink: function ($select) {
        $select.on("change", function () {
          var url = $select.val();
          if (url != "") {
            document.location = url;
          }
        });
        SelectLinks.markAsActiveForUrl($select, SelectLinks.currentUrl);
      },

      init: function () {
        SelectLinks.$linkableSelects = $("[data-select-link]");
        SelectLinks.currentUrl = document.location.pathname;
        SelectLinks.$linkableSelects.each(function () {
          SelectLinks.bindSelectLink($(this));
        });
      },
    });

    SelectLinks.init();
  });
})(document, window, jQuery);
