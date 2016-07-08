/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:tabs", function () {

    var getWidthOfTabRow = function($tabset) {
      var $links = $tabset.find("li");
      var widthOfTabs = 0;
      $links.each(function(){
        widthOfTabs = widthOfTabs + $(this).outerWidth();
      });
      return widthOfTabs;
    }

    var areTabsGoingToWrap = function($tabset) {
      var tabWidth = getWidthOfTabRow($tabset);
      var tabPanesWidth = $tabset.outerWidth() - 10; // some buffer for good measure

      if( !$tabset.is("[data-tab-width]") ) {
        $tabset.attr("data-tab-width", tabWidth);
      }

      return $tabset.attr("data-tab-width") > tabPanesWidth;
    }

    // Push the current pane to the select menu
    // Used for two-way binding of select and desktop tabs
    var updateSelect = function($tabset) {
      var $fallbackSelect = $tabset.find(".tabs--fallback-select");
      if($fallbackSelect.length) {
        // var activePane = getActivePane($tabset);
        // $fallbackSelect.val(activePane);
      }

    }

    // Check if a select menu should be visible or not as a fallback for tabs
    // on smaller screen sizes
    var checkIfTabsNeedSelectMenu = function($tabset) {
      var $tabLinks = $tabset.children("ul");

      // check if there's already a select menu ready to be used
      var $fallbackSelect = $tabset.find(".tabs--fallback-select");

      // scaffold up a new select menu
      if( $fallbackSelect.length < 1 ) {
        $fallbackSelect = $("<select class='tabs--fallback-select' />");
        // build the options
        $tabLinks.find("li").each(function(){
          var $thisLink = $(this).children("[data-toggle-anchor]");
          var tabID = $thisLink.attr("data-toggle-anchor");
          var tabLabel = $thisLink.text();
          var $optionElement = $("<option />");
          $optionElement.attr({
            "data-tab-option": tabID,
            "value": tabID
          }).text(tabLabel);
          $optionElement.appendTo($fallbackSelect);
        });
        $tabset.prepend($fallbackSelect);
        // on change functionality to update tabs
        $fallbackSelect.on("change", function(){
          var tabPaneId = $fallbackSelect.val();
          var $toggleAnchor = $tabLinks.find("[data-toggle-anchor=" + tabPaneId + "]");
          $toggleAnchor.click();
          // loadTab($tabset, pane);
          // pushHashToLocation($tabset, pane);
        });
        // update selected option if required
        updateSelect($tabset);
      }

      // show the select menu if the tabs need to wrap
      if(areTabsGoingToWrap($tabset)) {
        $tabLinks.hide();
        $fallbackSelect.show();
      } else {
        $tabLinks.show();
        $fallbackSelect.hide();
      }
    }

    var $tabSets = $("[data-tabs]");
    var $tabPanes = $("[data-tab-for]");

    $tabSets.each(function(i){
      var $tabs = $(this);
      var $tabLinks = $tabs.find("[data-tab]");
      var tabGroup = "tab-group-" + i;

      if($tabs.attr("data-tabs")) {
        tabGroup = $tabs.attr("data-tabs") + tabGroup;
      }

      // Update link attributes to use toggle attributes
      $tabLinks.each(function(){
        var $tabLink = $(this);
        $tabLink.attr({
          "data-toggle-anchor": $tabLink.attr("data-tab"),
          "data-toggle-one-way": "",
          "data-toggle-speed": "0",
          "data-toggle-group": tabGroup,
          "data-toggle-tab": ""
        }).removeAttr("data-tab");

        if($tabs.is("[data-tabs-deeplink]")) {
          $tabLink.attr({
            "data-toggle-deeplink-tab": ""
          });
        }

        // after change
        $tabLink.on("toggle:toggled", function(){
          $(document).trigger("ornament:tab-change");
        });
      });

      // Set first as active
      $tabLinks.first().addClass("active");

      // Fallback to select menu if necessary
      checkIfTabsNeedSelectMenu($(this));
      
    });

    // Update pane attributes to use toggle attributes
    $tabPanes.each(function(){
      var $pane = $(this);
      $pane.attr({
        "data-toggle": $pane.attr("data-tab-for"),
        "data-toggle-tab-pane": ""
      }).removeAttr("data-tab-for");
    });

    // Set first as active
    $tabPanes.first().addClass("tabs--pane__active");

    // Deeplinking
    var hash = document.location.hash;
    if(hash) {
      // remove hash symbol from hash
      // (#thing = thing)
      var hash = hash.substr(1,hash.length); 
      var $pane = $tabPanes.filter("[data-toggle-tab-pane][data-toggle=" + hash + "]");
      if($pane.length) {
        // click the appropriate toggle
        var $anchor = $("[data-toggle-tab][data-toggle-anchor=" + hash + "]");
        $(document).on("ornament:toggles", function(){
          $anchor.trigger("ornament:toggle-on");
        });
      }
    }

    // On resize
    $(window).on("resize", function(){
      $tabSets.each(function(){
        var $tabset = $(this);
        // Check if a select menu is needed
        checkIfTabsNeedSelectMenu($tabset);
      });
    });

  });

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:tabs");
  });

}(document, window, jQuery));
// 