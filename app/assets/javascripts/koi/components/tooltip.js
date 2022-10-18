/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    // settings
    var repositionOnEdge = true;
    var defaultPosition = "right middle";
    var followMouse = false;
    var toggleTooltips = false;
    var $tooltipAnchors = $("[data-tooltip]");

    // positioning offsets/gutters (eg. 10px from edge of screen)
    var offsetTop = 10;
    var offsetLeft = 10;
    var offsetRight = 10;
    var offsetBottom = 10;

    // Calculate everything and position the tooltip in the appropriate place
    var positionTooltip = function ($tooltip, $anchor, e) {
      var mousePos = false || e;
      var positionTo = defaultPosition;
      var positionLeft = 0;
      var positionTop = 0;

      if ($anchor.is("[data-tooltip-position]")) {
        positionTo = $anchor.attr("data-tooltip-position");
      }

      var tooltipHeight = $tooltip.find(".tooltip--inner").outerHeight();
      var tooltipWidth = $tooltip.find(".tooltip--inner").outerWidth();

      var anchorHeight = $anchor.outerHeight();
      var anchorWidth = $anchor.outerWidth();

      var anchorLeft = $anchor.offset().left;
      var anchorTop = $anchor.offset().top;
      var anchorRight = anchorLeft + anchorWidth;
      var anchorBottom = anchorTop + anchorHeight;

      // replace anchor positioning with mouse position if required
      if (mousePos) {
        var anchorLeft = mousePos.pageX - offsetLeft;
        var anchorRight = mousePos.pageX + offsetRight;
        var anchorTop = mousePos.pageY - offsetTop;
        var anchorBottom = mousePos.pageY + offsetBottom;
        var anchorWidth = 20;
        var anchorHeight = 20;
      }

      var anchorTopRelativeToViewPort = anchorTop - $(document).scrollTop();
      var anchorTopRelativeToViewPortAndTooltip =
        anchorTopRelativeToViewPort - tooltipHeight;

      var anchorLeftAndTooltip = anchorLeft - tooltipWidth;
      var anchorRightAndTooltip = anchorRight + tooltipWidth;
      var anchorTopAndTooltip = anchorTop + tooltipHeight;

      var anchorBottomRelativeToViewPort =
        anchorTopRelativeToViewPort + anchorHeight;
      var anchorBottomRelativeToViewPortAndTooltip =
        anchorBottomRelativeToViewPort + tooltipHeight;

      var anchorMiddleX = anchorRight - anchorWidth / 2;
      var anchorMiddleY = anchorBottom - anchorHeight / 2;

      var windowWidth = Ornament.windowWidth() - offsetLeft - offsetRight;
      var windowHeight = Ornament.windowHeight() - offsetTop - offsetBottom;

      var positionClasses =
        "ttop tright tleft tbottom atop aright amiddle aleft abottom";

      // check if we should be repositioning this tooltip
      var repositionTooltip = repositionOnEdge;
      if ($anchor.is("[data-tooltip-static]")) {
        repositionTooltip = false;
      }

      // check what available space there is and update the positionTo variable
      if (repositionTooltip) {
        var positionTooltip = positionTo.split(" ")[0];
        var positionArrow = positionTo.split(" ")[1];

        // TOOLTIP SPACING
        var notEnoughRoomOnLeft = anchorLeftAndTooltip < offsetLeft;
        var notEnoughRoomOnRight = anchorRightAndTooltip > windowWidth;
        var notEnoughRoomOnTop =
          anchorTopRelativeToViewPortAndTooltip < offsetTop;
        var notEnoughRoomOnBottom =
          anchorBottomRelativeToViewPortAndTooltip > windowHeight;

        // Move to bottom if not enough space on left or right
        if (positionTooltip == "left" || positionTooltip == "right") {
          if (notEnoughRoomOnLeft && notEnoughRoomOnRight) {
            positionTooltip = "bottom";
            positionArrow = "middle";
          } else if (positionTooltip == "left" && notEnoughRoomOnLeft) {
            positionTooltip = "right";
          } else if (positionTooltip == "right" && notEnoughRoomOnRight) {
            positionTooltip = "left";
          }
        }

        // Move to bottom if not enough space on top
        if (
          (positionTooltip == "top" || positionTooltip == "bottom") &&
          notEnoughRoomOnTop &&
          notEnoughRoomOnBottom
        ) {
          positionTooltip = "bottom";
        } else {
          if (positionTooltip == "top" && notEnoughRoomOnTop) {
            positionTooltip = "bottom";
            positionArrow = "middle";
          } else if (positionTooltip == "bottom" && notEnoughRoomOnBottom) {
            positionTooltip = "top";
          }
        }

        // ARROW SPACING
        var notEnoughRoomForArrowTop =
          anchorTopRelativeToViewPort + tooltipHeight > windowHeight;
        var notEnoughRoomForArrowBottom =
          anchorBottomRelativeToViewPort - tooltipHeight < offsetTop;
        var notEnoughRoomForArrowRight =
          anchorRight - tooltipWidth < offsetLeft;
        var notEnoughRoomForArrowLeft = anchorLeft + tooltipWidth > windowWidth;

        // horizontal middle positioning
        if (
          (positionTooltip == "top" || positionTooltip == "bottom") &&
          positionArrow == "middle"
        ) {
          if (notEnoughRoomForArrowLeft && notEnoughRoomForArrowRight) {
            positionArrow = "middle";
          } else if (notEnoughRoomForArrowLeft) {
            positionArrow = "right";
          } else if (notEnoughRoomForArrowRight) {
            positionArrow = "left";
          }
        }

        // vertical middle positioning
        if (
          (positionTooltip == "left" || positionTooltip == "right") &&
          positionArrow == "middle"
        ) {
          if (notEnoughRoomForArrowTop && notEnoughRoomForArrowBottom) {
            positionArrow = "middle";
          } else if (notEnoughRoomForArrowTop) {
            positionArrow = "bottom";
          } else if (notEnoughRoomForArrowBottom) {
            positionArrow = "top";
          }
        }

        // top/bottom positioning, falling back to middle
        if (positionArrow == "top" || positionArrow == "bottom") {
          if (notEnoughRoomForArrowTop && notEnoughRoomForArrowBottom) {
            positionArrow = "middle";
          } else {
            if (positionArrow == "top" && notEnoughRoomForArrowTop) {
              positionArrow = "bottom";
            } else if (
              positionArrow == "bottom" &&
              notEnoughRoomForArrowBottom
            ) {
              positionArrow = "top";
            }
          }
        }

        // left/right positioning, falling back to middle
        if (positionArrow == "left" || positionArrow == "right") {
          if (notEnoughRoomForArrowLeft && notEnoughRoomForArrowRight) {
            positionArrow = "middle";
          } else {
            if (positionArrow == "left" && notEnoughRoomForArrowLeft) {
              positionArrow = "right";
            } else if (positionArrow == "right" && notEnoughRoomForArrowRight) {
              positionArrow = "left";
            }
          }
        }

        // update the positionTo variable in preparation for positioning
        positionTo = positionTooltip + " " + positionArrow;
      }

      // check the positionTo variable and set where the tooltip needs to be
      switch (positionTo) {
        // tops
        case "top left":
          positionLeft = anchorLeft;
          positionTop = anchorTop - tooltipHeight;
          break;

        case "top middle":
          positionLeft = anchorLeft + anchorWidth / 2 - tooltipWidth / 2;
          positionTop = anchorTop - tooltipHeight;
          break;

        case "top right":
          positionLeft = anchorRight - tooltipWidth;
          positionTop = anchorTop - tooltipHeight;
          break;

        // lefts
        case "left top":
          positionLeft = anchorLeft - tooltipWidth;
          positionTop = anchorTop;
          break;

        case "left middle":
          positionLeft = anchorLeft - tooltipWidth;
          positionTop = anchorMiddleY - tooltipHeight / 2;
          break;

        case "left bottom":
          positionLeft = anchorLeft - tooltipWidth;
          positionTop = anchorBottom - tooltipHeight;
          break;

        // bottoms
        case "bottom left":
          positionLeft = anchorLeft;
          positionTop = anchorBottom;
          break;

        case "bottom middle":
          positionLeft = anchorLeft + anchorWidth / 2 - tooltipWidth / 2;
          positionTop = anchorBottom;
          break;

        case "bottom right":
          positionLeft = anchorRight - tooltipWidth;
          positionTop = anchorBottom;
          break;

        // rights
        case "right bottom":
          positionLeft = anchorRight;
          positionTop = anchorBottom - tooltipHeight;
          break;

        case "right middle":
          positionLeft = anchorRight;
          positionTop = anchorMiddleY - tooltipHeight / 2;
          break;

        case "right top":
          positionLeft = anchorRight;
          positionTop = anchorTop;
          break;

        default:
          // right top if not matching anything above
          positionLeft = anchorRight;
          positionTop = anchorTop;
          break;
      }

      // tooltip class
      var positionClass =
        "t" + positionTo.split(" ")[0] + " a" + positionTo.split(" ")[1];

      // update classes on the tooltip for styling purposes
      $tooltip.removeClass(positionClasses).addClass(positionClass);

      // finally, position the tooltip
      $tooltip.css({
        left: positionLeft,
        top: positionTop,
      });
    };

    // General "show" function
    var showTooltip = function ($tooltip, $anchor) {
      $("body").prepend($tooltip);
      positionTooltip($tooltip, $anchor);
    };

    // General "hide" function
    var hideTooltip = function ($tooltip) {
      $tooltip.remove();
    };

    // Reposition tooltips on window resize
    var repositionTooltips = function () {
      $(".tooltip--inner").each(function () {
        var $tooltip = $(this).parent();
        var thisId = $tooltip.attr("data-tooltip-from");
        var $anchor = $("[data-tooltip='" + thisId + "']");
        positionTooltip($tooltip, $anchor);
      });
    };

    // Build tooltips and attach to each tooltip anchor
    $tooltipAnchors
      .not(".tooltip__init")
      .each(function (i) {
        var $anchor, $wrapper, $outer, $inner, $arrow, $content, $text;

        $anchor = $(this);
        $wrapper = $('<span class="tooltip--wrapper" />');
        $outer = $(
          '<div class="tooltip--outer" data-tooltip-from="' +
            $anchor.attr("data-tooltip") +
            '" />'
        );
        $inner = $('<div class="tooltip--inner"/>');
        $arrow = $('<div class="tooltip--arrow"/>');
        $content = $('<div class="tooltip--content"/>');
        if ($anchor.is("[data-tooltip-basic]")) {
          $text = $anchor.attr("title");
          $anchor.attr("title", "");
        } else {
          $text = $(
            "[data-tooltip-for='" + $(this).attr("data-tooltip") + "']"
          ).html();
        }

        // Put all the parts together.
        $wrapper.append($outer);
        $outer.append($inner);
        $inner.append($arrow);
        $inner.append($content);
        $content.append($text);

        // Reposition tooltip to mouse if required
        if (followMouse || $anchor.is("[data-tooltip-follow]")) {
          $anchor.on("mousemove", function (e) {
            positionTooltip($outer, $anchor, e);
          });
        }

        // Show/Hide tooltips
        if (toggleTooltips || $anchor.is("[data-tooltip-toggle]")) {
          // Toggle on click
          $anchor.on("click", function (e) {
            e.preventDefault();
            if ($inner.is(":visible")) {
              hideTooltip($outer);
            } else {
              showTooltip($outer, $anchor);
            }
          });

          // Always on tooltips
          if ($anchor.is("[data-tooltip-show]")) {
            showTooltip($outer, $anchor);
          }
        } else {
          // Always on tooltips
          if ($anchor.is("[data-tooltip-show]")) {
            showTooltip($outer, $anchor);
          } else {
            // Toggle on hover
            $anchor.hover(
              function () {
                showTooltip($outer, $anchor);
              },
              function () {
                hideTooltip($outer);
              }
            );
          }
        }
      })
      .addClass("tooltip__init");

    // Window resize functions
    $(window).on("resize", function () {
      repositionTooltips();
    });
  });
})(document, window, jQuery);
