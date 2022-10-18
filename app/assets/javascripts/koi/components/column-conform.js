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
    el.data(
      "originalHeight",
      el.data("originalHeight") == undefined
        ? el.height()
        : el.data("originalHeight")
    );
    el.height(newHeight);
  }

  function setConformingHeightLast(el, els, newHeight) {
    el.data(
      "originalHeight",
      el.data("originalHeight") == undefined
        ? el.height()
        : el.data("originalHeight")
    );
    $.each(els, function () {
      $(this).height(newHeight);
    });
  }

  function getOriginalHeight(el) {
    // if the height has changed, send the originalHeight
    return el.css("height", "auto").height();
  }

  function columnConform() {
    var $conforms = $("[data-conform-columns]");
    var $slaveConforms = $("[data-conform-slave]");

    $conforms.each(function () {
      var $thisConform = $(this);
      var conformId = $thisConform.data("conform-columns");
      var $columns = $thisConform.find("[data-conform='" + conformId + "']");
      var currentTallest = 0;
      var rowDivs = [];

      // find the tallest DIV in the row, and set the heights of all of the DIVs to match it.
      $columns.each(function (index) {
        if (currentRowStart != $(this).position().top) {
          // we just came to a new row.  Set all the heights on the completed row
          for (var currentDiv = 0; currentDiv < rowDivs.length; currentDiv++)
            setConformingHeight(rowDivs[currentDiv], currentTallest);

          // set the variables for the new row
          rowDivs.length = 0; // empty the array
          currentRowStart = $(this).position().top;
          currentTallest = getOriginalHeight($(this));
          rowDivs.push($(this));
        } else {
          // another div on the current row.  Add it to the list and check if it's taller
          rowDivs.push($(this));
          currentTallest =
            currentTallest < getOriginalHeight($(this))
              ? getOriginalHeight($(this))
              : currentTallest;
        }

        if (
          $thisConform.find("[data-conform='" + conformId + "']").length == 2
        ) {
          for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++)
            setConformingHeightLast(
              rowDivs[currentDiv],
              rowDivs,
              currentTallest
            );
        } else {
          for (currentDiv = 0; currentDiv < rowDivs.length; currentDiv++)
            setConformingHeight(rowDivs[currentDiv], currentTallest);
        }
      });
    });

    // Slave Conforms are boxes that size based on another box, but the other box doesn't size based on this box.
    $slaveConforms.each(function () {
      var $slave = $(this);
      var slaveId = $slave.attr("data-conform-slave");
      var slaveOffset = $slave.offset().top;

      // Check for available masters
      var $master = false;
      var $potentialMasters = $("[data-conform='" + slaveId + "']");

      // Loop over each master and check if they have the same offset().top
      $potentialMasters.each(function () {
        // If there's already a matching master, abort, we only need one.
        // We can assume the masters are already conforming themselves
        if ($master) {
          return false;
        }
        // If there is no master, check the offset matches the slave and make this
        // the master
        var $thisMaster = $(this);
        if ($thisMaster.offset().top == slaveOffset) {
          $master = $thisMaster;
        }
      });

      // If there is a master, set the slave to be the same height
      // If there is no master, set the slave to be auto height
      if ($master) {
        $slave.outerHeight($master.outerHeight());
      } else {
        $slave.css("height", "auto");
      }
    });
  }

  var debounceConform = function () {
    // set up rate limiter flag, queue and timeout
    var canConform = true;
    var canConformQueue = 0;
    var canConformTimeout;

    // check if it can conform
    // it won't be able to if conform was recently called
    if (canConform) {
      columnConform();

      // rate limit
      canConform = false;
      canConformTimeout = setTimeout(function () {
        canConform = true;
        if (canConformQueue > 0) {
          columnConform();
        }
      }, 1000);
    } else {
      // if it can't conform, add to the queue
      canConformQueue = canConformQueue + 1;
    }
  };

  $(document).on("ornament:column-conform", function () {
    // call column conform
    debounceConform();

    // call again when images have loaded
    $("[data-conform]")
      .find("img")
      .on("load", function () {
        debounceConform();
      });
  });

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:column-conform");
  });

  $(document).on("ornament:tab-change", function () {
    $(document).trigger("ornament:column-conform");
  });

  $(window).on("resize", function () {
    $(document).trigger("ornament:column-conform");
  });
})(document, window, jQuery);
