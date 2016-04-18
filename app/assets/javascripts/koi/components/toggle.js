/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    var $toggleAnchors = $("[data-toggle-anchor]");
    var $toggles = $("[data-toggle]");
    var $temporaryToggles = $("[data-toggle-temporary]");
    var toggleOnClass = "active";
    var headerBreakpoint = Ornament.headerBreakpoint;

    var toggleOn = function($toggleAnchor, $toggleContent) {
      var toggleId = $toggleAnchor.attr("data-toggle-anchor");
      var $thisToggleAnchors = $("[data-toggle-anchor="+toggleId+"]");
      var focusOnField = $toggleAnchor.is("[data-toggle-focus]");

      // Toggle a visible class
      $thisToggleAnchors.addClass(toggleOnClass);

      // Swap label if needed
      if($toggleAnchor.is("[data-toggle-visible-label]")) {
        $toggleAnchor.text($toggleAnchor.attr("data-toggle-visible-label"));
      }

      // Hide other toggle anchors if needed
      if($toggleAnchor.is("[data-toggle-group]")) {
        var toggleGroupId = $toggleAnchor.attr("data-toggle-group");
        var $otherToggleAnchors = $toggleAnchors.filter("[data-toggle-group="+toggleGroupId+"]").not($toggleAnchor);
        $otherToggleAnchors.each(function(){
          var $otherToggleAnchor = $(this);
          var otherToggleId = $otherToggleAnchor.attr("data-toggle-anchor");
          var $otherToggleContent = $("[data-toggle="+otherToggleId+"]");
          toggleOff($otherToggleAnchor, $otherToggleContent);
        });
      }

      // Toggle sliding
      $toggleContent.slideDown(function(){
        if(focusOnField) {
          var $inputs = $toggleContent.find("input");
          var $textareas = $toggleContent.find("textarea");
          if($inputs.length) {
            $inputs.first().focus();
          } else if($textareas.length) {
            $textareas.first().focus();
          }
        }
      });
    }

    var toggleOff = function($toggleAnchor, $toggleContent) {
      var toggleId = $toggleAnchor.attr("data-toggle-anchor");
      var $thisToggleAnchors = $("[data-toggle-anchor="+toggleId+"]");

      // Toggle visible class
      $thisToggleAnchors.removeClass(toggleOnClass);

      // Swap label if needed
      if($toggleAnchor.is("[data-toggle-hidden-label]")) {
        $toggleAnchor.text($toggleAnchor.attr("data-toggle-hidden-label"));
      }

      // Slide content
      $toggleContent.slideUp(200);

      // Scroll if needed
      if($toggleAnchor.is("[data-toggle-scroll]")) {
        // Find the master toggle and find it's offset top
        var $toggleMaster = $thisToggleAnchors.filter("[data-toggle-scroll-master]");
        var masterOffsetTop = $toggleMaster.offset().top;

        // Account for sticky header
        // masterOffsetTop = masterOffsetTop - Ornament.stickyHeightComparison(masterOffsetTop);

        // Check if user has scrolled past the master element
        // we don't want the user to be scrolled down, only up
        var scrollTop = $(document).scrollTop();
        if(scrollTop > masterOffsetTop) {
          // Animate up
          $("html,body").animate({
            scrollTop: masterOffsetTop
          }, 200);
        }
      }
    }

    var toggle = function($toggleAnchor, $toggleContent) {

      if($toggleContent.is(":animated")) {
        return false;
      }

      if($toggleAnchor.hasClass(toggleOnClass)) {
        toggleOff($toggleAnchor, $toggleContent);
      } else {
        toggleOn($toggleAnchor, $toggleContent);
      }

    }

    // Hid all toggles on page
    var hideAllToggles = function(){
      $toggles.not("[data-toggle-default]").hide();
    }

    // Hide all toggles by default
    hideAllToggles();

    $toggleAnchors.each(function(){
      var $toggleAnchor = $(this);
      var toggleId = $toggleAnchor.attr("data-toggle-anchor");
      var $toggleContent = $("[data-toggle=" + toggleId + "]");

      // Cache old text value if we need to swap labels
      if($toggleAnchor.is("[data-toggle-visible-label]")) {
        $toggleAnchor.attr("data-toggle-hidden-label", $toggleAnchor.text());
      }

      // Clicking on anchors
      $toggleAnchor.on("click", function(e){
        e.preventDefault();
        toggle($toggleAnchor, $toggleContent);
      });

      // Bind some events
      $toggleAnchor.bind("ornament:toggle-on", function(){
        toggleOn($toggleAnchor, $toggleContent);
      });
      $toggleAnchor.bind("ornament:toggle-off", function(){
        toggleOff($toggleAnchor, $toggleContent);
      });
      $toggleAnchor.bind("ornament:toggle", function(){
        toggle($toggleAnchor, $toggleContent);
      });
      $(document).bind("ornament:toggle-all-off", function(){
        hideAllToggles();
      });

    });

    var hideTemporaryToggles = function(){
      $temporaryToggles.each(function(){
        var $toggleContent = $(this);
        var toggleId = $toggleContent.attr("data-toggle");
        var $toggleAnchor = $("[data-toggle-anchor=" + toggleId + "]");
        toggleOff($toggleAnchor, $toggleContent);
      });
    }

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
    $("[data-toggle-temporary-anchor]").on("click onfocus touch", function (event) {
      event.stopPropagation();
    });

  });

}(document, window, jQuery));