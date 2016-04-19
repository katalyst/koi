/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    var $linkableSelects = $("[data-select-link]");
    var currentUrl = document.location.pathname;

    // On click change
    $linkableSelects.each(function(){

      var $thisSelect = $(this);

      $thisSelect.on("change", function(){
        var url = $thisSelect.val();
        if(url != "") {
          document.location = url;
        }
      });

      // Default state
      if ( $thisSelect.find("option[value='"+currentUrl+"']").length > 0 ) {
        $thisSelect.val(currentUrl);
      }

    });

  });

}(document, window, jQuery));