/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

// Converts this:
//
// <nav class="navigation">
//   <ul>
//     <li>
//       <a href="#">About</a>
//       <ul>
//         <li>
//           <a href="#">History</a>
//         </li>
//       </ul>
//     </li>
//   </ul>
// </nav>
//
// Into this:
//
// <nav class="navigation">
//   <ul>
//     <li>
//       <button>About</button>
//       <ul>
//         <li>
//           <a href="#">History</a>
//         </li>
//       </ul>
//     </li>
//   </ul>
// </nav>
//
// And will toggle the visiblity on nested UL's when their corresponding button
// is clicked.
//

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {
    $(".navigation").each(function () {

      var $nav = $(this);

      $nav.find("li > * + ul").prev().each(function () {
        var $link, $button;

        $link = $(this);
        $button = $("<button/>");

        $button.append($link.contents());
        $link.after($button);
        $link.remove();

        $button.next("ul").hide();

        $button.on("click", function () {
          var $ul, visible;

          $ul = $button.next("ul");
          visible = $ul.is(":visible");

          $button.closest("ul").find("li > ul").hide();

          if (!visible) {
            $ul.show();
            if ($button.is(":focus")) {
              $ul.find("a").first().focus();
            }
          }
        });
      });

      // If the user clicks on something (or tab to something) outside of the nav,
      // collapse any open sub nav lists.
      $("html").on("click onfocus touch", function () {
        $nav.find("li > * + ul").hide();
      });

      // Prevent "click" and "onfocus" events from propagating throught to the
      // HTML element.
      $nav.on("click onfocus touch", function (event) {
        event.stopPropagation();
      });

    });
  });

}(document, window, jQuery));
