/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  var turbolinks = true;

  Ornament.refresh = function(){
    $(document).trigger("ornament:refresh");
    Ornament.ready = true;
  }

  $(document).on("pjax:end", "*", function () {
    Ornament.refresh();
  });

  if(!Ornament.features.turbolinks) {
    $(document).on("ready", function () {
      Ornament.refresh();
    });
  }

}(document, window, jQuery));
