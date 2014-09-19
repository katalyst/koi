/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  // conform variables
  var currentTallest = 0;
  var currentRowStart = 0;
  var rowDivs = new Array();

  function setConformingHeight(el, newHeight) {
   // set the height to something new, but remember the original height in case things change
   el.data("originalHeight", (el.data("originalHeight") == undefined) ? (el.height()) : (el.data("originalHeight")));
   el.height(newHeight);
  }

  function getOriginalHeight(el) {
   // if the height has changed, send the originalHeight
   // return (el.data("originalHeight") == undefined) ? (el.css("height","auto").height()) : (el.data("originalHeight"));
   return el.css("height","auto").height();
  }

  function columnConform() {

    var $columns = $("[data-conform-columns]").find("[data-conform]");

    // find the tallest DIV in the row, and set the heights of all of the DIVs to match it.
    $columns.each(function(index) {

      if(currentRowStart != $(this).position().top) {

        // we just came to a new row.  Set all the heights on the completed row
        for(var currentDiv = 0 ; currentDiv < rowDivs.length ; currentDiv++) setConformingHeight(rowDivs[currentDiv], currentTallest);

        // set the variables for the new row
        rowDivs.length = 0; // empty the array
        currentRowStart = $(this).position().top;
        currentTallest = getOriginalHeight($(this));
        rowDivs.push($(this));

      } else {

        // another div on the current row.  Add it to the list and check if it's taller
        rowDivs.push($(this));
        currentTallest = (currentTallest < getOriginalHeight($(this))) ? (getOriginalHeight($(this))) : (currentTallest);

      }

      // do the last row
      for(currentDiv = 0 ; currentDiv < rowDivs.length ; currentDiv++) setConformingHeight(rowDivs[currentDiv], currentTallest);

    });
  }


  $(document).on("ornament:refresh", function () {

    // call column conform
    columnConform();

    // call again when images have loaded
    $("[data-conform-columns]").find("img").on("load",function(){
      debounce(columnConform(),200);
    });

    // call again when resizing browser
    $(window).on("resize", function(){
      debounce(columnConform(),200);
    });

  });

  $(document).on("ornament:column-conform", function () {
    columnConform();
  });

}(document, window, jQuery));