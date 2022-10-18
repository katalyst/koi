/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

/*

  Used for creating buttons that can dismiss elements
  Add a data-dismiss attribute to your close button with the class of the element
  you want to dismiss. The close button will look for the closest element with that
  class and fade it out.

  <div class="my-element">
    <span data-dismiss="my-element">close this element</span>
  </div>

*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    var $dismisses = $("[data-dismiss]");

    $dismisses.each(function () {
      var $anchor = $(this);
      var $target = $anchor.closest("." + $anchor.attr("data-dismiss"));
      if ($target.length) {
        $anchor.on("click", function (e) {
          e.preventDefault();
          $target.fadeOut("fast", function () {
            $target.remove();
          });
        });
      }
    });
  });
})(document, window, jQuery);
