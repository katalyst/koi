/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:sticky-header");
  });

  $(document).on("ornament:sticky-header", function () {

    // Settings
    var $stickyHeader, fixedClass, stickyClass, $desktopHeader, headerBreakpoint;
    $stickyHeader = $(".sticky-header");
    fixedClass = "sticky-header__fixed";
    stickyClass = "sticky-header__stuck";
    $desktopHeader = $(".layout--header");
    headerBreakpoint = 0;

    // StickyHeader
    $stickyHeader.not(".sticky-header__init").each(function () {
      var $this, headerOffset, headerHeight, hasSticky;

      $this = $(this);
      headerOffset = $this.offset().top;
      headerHeight = $this.height();
      hasSticky = Modernizr.csspositionsticky;

      $(window).on("scroll", function() {
        // disable on mobile view
        if( Ornament.windowWidth() < headerBreakpoint ) {
          return false;
        }
        // update headerOffset
        if( !$this.hasClass(fixedClass) ) {
          headerOffset = $this.offset().top;
        }
        // update headerHeight if required
        headerHeight = $this.height();
        var scrollTop = $(window).scrollTop();

        // sticky check
        if(hasSticky){
          if(scrollTop >= headerOffset) {
            // if hasSticky, only add the sticky class
            $this.addClass(stickyClass);
          } else {
            $this.removeClass(stickyClass);
          }
        } else {
          // if doesn't support sticky, add sticky class + fixed class
          if(scrollTop > headerOffset) {
            $this.addClass(fixedClass).addClass(stickyClass);
            $desktopHeader.css("marginBottom",headerHeight);
          } else {
            $this.removeClass(fixedClass).removeClass(stickyClass);
            $desktopHeader.css("marginBottom","0");
          }
        }
      });

    }).addClass("sticky-header__init");

  });

}(document, window, jQuery));
