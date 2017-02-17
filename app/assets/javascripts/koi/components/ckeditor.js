/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {  
    // $(document).trigger("ornament:ck-editor");
  });

  $(document).on("ornament:tab-change", function () {  
    $(document).trigger("ornament:ck-editor");
  });

}(document, window, jQuery));