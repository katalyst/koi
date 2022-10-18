/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:toggles", function () {
    var $toggleAnchors = $("[data-toggle-anchor]");
    var $toggles = $("[data-toggle]");
    var $temporaryToggles = $("[data-toggle-temporary]");
    var toggleOnClass = "active";
    var headerBreakpoint = Ornament.headerBreakpoint;

    // Setup afterSlide function
    var afterSlide = function ($toggleContent, $toggleAnchor, on) {
      var on = on || false;
      var focusOnField = $toggleAnchor.is("[data-toggle-focus]");
      if (on && focusOnField) {
        var $inputs = $toggleContent.find("input");
        var $textareas = $toggleContent.find("textarea");
        if ($inputs.length) {
          $inputs.first().focus();
        } else if ($textareas.length) {
          $textareas.first().focus();
        }
      }
      Ornament.globalLightboxSizing();
    };

    var toggleOn = function ($toggleAnchor, $toggleContent) {
      var toggleId = $toggleAnchor.attr("data-toggle-anchor");
      var $thisToggleAnchors = $("[data-toggle-anchor=" + toggleId + "]");

      // Toggle a visible class
      $thisToggleAnchors.addClass(toggleOnClass);

      // Swap label if needed
      if ($toggleAnchor.is("[data-toggle-visible-label]")) {
        $toggleAnchor.text($toggleAnchor.attr("data-toggle-visible-label"));
      }

      // Hide other toggle anchors if needed
      if ($toggleAnchor.is("[data-toggle-group]")) {
        var toggleGroupId = $toggleAnchor.attr("data-toggle-group");
        var $otherToggleAnchors = $toggleAnchors
          .filter("[data-toggle-group=" + toggleGroupId + "]")
          .not($toggleAnchor);
        $otherToggleAnchors.each(function () {
          var $otherToggleAnchor = $(this);
          var otherToggleId = $otherToggleAnchor.attr("data-toggle-anchor");
          var $otherToggleContent = $("[data-toggle=" + otherToggleId + "]");
          toggleOff($otherToggleAnchor, $otherToggleContent);
        });
      }

      // Toggle sliding
      if ($toggleAnchor.is("[data-toggle-tab]")) {
        $toggleContent.addClass("tabs--pane__active");
      } else {
        var speed = $toggleAnchor.is("[data-toggle-speed]")
          ? parseInt($toggleAnchor.attr("data-toggle-speed"))
          : 200;
        $toggleContent.stop().slideDown(speed, function () {
          afterSlide($toggleContent, $toggleAnchor, true);
        });
      }

      $toggleAnchor.trigger("ornament:toggle:after-toggle-on");
    };

    var toggleOff = function ($toggleAnchor, $toggleContent) {
      var toggleId = $toggleAnchor.attr("data-toggle-anchor");
      var $thisToggleAnchors = $("[data-toggle-anchor=" + toggleId + "]");

      // Toggle visible class
      $thisToggleAnchors.removeClass(toggleOnClass);

      // Swap label if needed
      if ($toggleAnchor.is("[data-toggle-hidden-label]")) {
        $toggleAnchor.text($toggleAnchor.attr("data-toggle-hidden-label"));
      }

      // Slide content
      if ($toggleContent.is("[data-toggle-tab-pane]")) {
        $toggleContent.removeClass("tabs--pane__active");
      } else {
        var speed = $toggleAnchor.is("[data-toggle-speed]")
          ? parseInt($toggleAnchor.attr("data-toggle-speed"))
          : 200;
        $toggleContent.stop().slideUp(speed, function () {
          afterSlide($toggleContent, $toggleAnchor);
        });
      }

      // Scroll if needed
      if ($toggleAnchor.is("[data-toggle-scroll]")) {
        // Find the master toggle and find it's offset top
        var $toggleMaster = $thisToggleAnchors.filter(
          "[data-toggle-scroll-master]"
        );
        var masterOffsetTop = $toggleMaster.offset().top;

        // Account for sticky header
        // masterOffsetTop = masterOffsetTop - Ornament.stickyHeightComparison(masterOffsetTop);

        // Check if user has scrolled past the master element
        // we don't want the user to be scrolled down, only up
        var scrollTop = $(document).scrollTop();
        if (scrollTop > masterOffsetTop) {
          // Animate up
          $("html,body").animate(
            {
              scrollTop: masterOffsetTop,
            },
            200
          );
        }
      }
    };

    var toggle = function ($toggleAnchor, $toggleContent) {
      var oneWay = false;
      if ($toggleAnchor.is("[data-toggle-one-way]")) {
        oneWay = true;
      }

      // Abort if animating
      if ($toggleContent.is(":animated")) {
        return false;
      }

      // Abort if one-way and already active
      if (oneWay && $toggleAnchor.is("." + toggleOnClass)) {
        return false;
      }

      if ($toggleAnchor.hasClass(toggleOnClass) && !oneWay) {
        toggleOff($toggleAnchor, $toggleContent);
      } else {
        toggleOn($toggleAnchor, $toggleContent);
      }

      $toggleAnchor.trigger("toggle:toggled");
    };

    // Hid all toggles on page
    var hideAllToggles = function () {
      $toggles.not("[data-toggle-default]").each(function () {
        var $togglePane = $(this);
        if (
          $("[data-toggle-anchor=" + $togglePane.attr("data-toggle") + "]").is(
            ".active"
          )
        ) {
          //
        } else if ($togglePane.is("[data-toggle-tab-pane]")) {
          //
        } else {
          $togglePane.hide();
        }
      });
    };

    Ornament.toggle = function ($toggleAnchor, $toggleContent) {
      toggle($toggleAnchor, $toggleContent);
    };

    // Hide all toggles by default
    hideAllToggles();

    $toggleAnchors
      .not("[data-toggle-anchor-init]")
      .each(function () {
        var $toggleAnchor = $(this);
        var toggleId = $toggleAnchor.attr("data-toggle-anchor");
        var $toggleContent = $("[data-toggle=" + toggleId + "]");

        // Cache old text value if we need to swap labels
        if ($toggleAnchor.is("[data-toggle-visible-label]")) {
          $toggleAnchor.attr("data-toggle-hidden-label", $toggleAnchor.text());
        }

        // Clicking on anchors
        $toggleAnchor.on("click", function (e) {
          e.preventDefault();
          toggle($toggleAnchor, $toggleContent);
        });

        // Bind some events
        $toggleAnchor.bind("ornament:toggle-on", function () {
          toggleOn($toggleAnchor, $toggleContent);
        });
        $toggleAnchor.bind("ornament:toggle-off", function () {
          toggleOff($toggleAnchor, $toggleContent);
        });
        $toggleAnchor.bind("ornament:toggle", function () {
          toggle($toggleAnchor, $toggleContent);
        });
        $(document).bind("ornament:toggle-all-off", function () {
          hideAllToggles();
        });
      })
      .attr("data-toggle-anchor-init", "");

    var hideTemporaryToggles = function () {
      $temporaryToggles.each(function () {
        var $toggleContent = $(this);
        var toggleId = $toggleContent.attr("data-toggle");
        var $toggleAnchor = $("[data-toggle-anchor=" + toggleId + "]");
        toggleOff($toggleAnchor, $toggleContent);
      });
    };

    // If the user clicks on something (or tab to something) outside of the nav,
    // collapse any relevant toggles
    $("html").on("click onfocus touch", function () {
      hideTemporaryToggles();
    });

    // Prevent "click" and "onfocus" events from propagating throught to the
    // HTML element.
    $temporaryToggles.on("click onfocus touch", function (event) {
      event.stopPropagation();
    });
    $("[data-toggle-temporary-anchor]").on(
      "click onfocus touch",
      function (event) {
        event.stopPropagation();
      }
    );
  });

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:toggles");
  });
})(document, window, jQuery);
