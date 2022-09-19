/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    var $nestedFields = $("[data-inline-nested]");
    var visibleClass = "nested-fields-visible";
    var visibleContainerClass = "active";
    var onlyOneNested = false;

    var getHeadingForPane = function($pane) {
      return $pane.find("[data-inline-nested-field-heading]");
    }

    var getContentForPane = function($pane) {
      return $pane.children(".nested-inline-fields");
    }

    var getToggleButtonForPane = function($pane) {
      return $pane.find("[data-inline-nested-field-toggle]");
    }

    // Show inline item regardless of current state
    var showNestedPane = function($pane) {
      $pane.addClass(visibleContainerClass);
      getHeadingForPane($pane).addClass(visibleClass);
      getToggleButtonForPane($pane).attr("aria-expanded", true);
      getContentForPane($pane).stop().slideDown('fast', function(){
        Ornament.globalLightboxSizing();
      });
      // Hide other ones if configured
      if(onlyOneNested) {
        $pane.siblings().each(function(){
          var $siblingPane = $(this);
          $siblingPane.removeClass(visibleContainerClass);
          var $heading = getHeadingForPane($siblingPane);
          $heading.removeClass(visibleClass);
          getContentForPane($siblingPane).hide();
          getToggleButtonForPane($siblingPane).attr("aria-expanded", false);
        });
      }
    }

    // Hide inline item regardless of current state
    var hideNestedPane = function($pane) {
      $pane.removeClass(visibleContainerClass);
      getHeadingForPane($pane).removeClass(visibleClass);
      getToggleButtonForPane($pane).attr("aria-expanded", false);
      getContentForPane($pane).stop().slideUp('fast', function(){
        Ornament.globalLightboxSizing();
      });
    }

    // Either show or hide based on current state
    var toggleNestedPane = function($pane) {
      if($pane.is(".active")) {
        hideNestedPane($pane);
      } else {
        showNestedPane($pane);
      }
    }

    // Generic function to update ordinal fields based on order of items
    var updateOrdinal = function(fields) {
      fields.children(".inline-ordinal-wrapper").find('.inline-ordinal').each(function(i, e) {
        $(e).val(i);
      });
    }

    // Some global bindings for programatic state setting if needed
    $nestedFields.each(function(){
      var $inlineNested = $(this);
      $inlineNested.bind("koi:inline-nested:make-sortable", function(){
        makeNestedSortable($inlineNested);
      });
      $inlineNested.bind("koi:inline-nested:make-unsortable", function(){
        makeNestedUnsortable($inlineNested);
      });
    });

    // Clicking on collapser will toggle the pane
    $("body").off("click", ".collapser").on("click", ".collapser", function (event) {
      event.preventDefault();
      toggleNestedPane($(this).closest(".nested-fields"));
    });

    // Show the new item and collapse the others
    $(document).on("ornament:inline-nested:insert", function(event, insertedItem) {
      showNestedPane(insertedItem);
      Ornament.C.FormHelpers.init();
      // Find the parent inline nested element and check if we
      // need to update ordinals
      var $inlineNested = insertedItem.closest("[data-inline-nested]");
      if($inlineNested.is("[data-inline-nested-sortable]")) {
        var nested_inline_fields = insertedItem.parent().children(".nested-fields");
        updateOrdinal(nested_inline_fields);
      }
      // Focus on the field
      if(Ornament.matchWhatInput(["keyboard", "mouse"])) {
        var $item = $(insertedItem).find(".nested-inline-fields");
        var $fields = $item.find("input,textarea,select");
        if($fields.length) {
          setTimeout(function(){
            $fields.first().focus();
          }, 300);
        } else {
          $item.find("[data-inline-nested-field-heading-name]").focus();
        }
      }
    });

    // Changing the re-ordering checkbox
    $("body").off("change", "[data-inline-nested-sortable-toggle]").on("change", "[data-inline-nested-sortable-toggle]", function() {

      var parent               = $(this).closest(".inline-nested--heading").next(".nested-wrapper");
      var nested_container     = parent.children(".nested-container")
      var nested_fields        = nested_container.children(".nested-fields");
      var nested_title_fields  = nested_fields.children("[data-inline-nested-field-heading]");
      var nested_inline_fields = nested_fields.children(".nested-inline-fields");
      var handlers             = nested_fields.children("[data-inline-nested-field-heading]").children(".drag-handler");

      if (this.checked) {

        parent.addClass("nested-wrapper-ordering");
        nested_inline_fields.hide();
        nested_container.children(".nested-links").hide();
        nested_title_fields.removeClass("nested-fields-visible");
        nested_title_fields.children(".collapser").addClass("no-collapser").removeClass("collapser");
        nested_title_fields.children(".drag-handler").show().addClass("drag-me");
        nested_fields.removeClass("active");

        nested_container.sortable({
          axis: "y",
          handle: ".drag-me",
          stop: function( event, ui ) {
            updateOrdinal(nested_fields);
          }
        });

      } else {

        parent.removeClass("nested-wrapper-ordering");
        nested_container.children(".nested-links").show();
        nested_fields.children("[data-inline-nested-field-heading]").children(".drag-handler").hide().removeClass("drag-me");
        nested_fields.children("[data-inline-nested-field-heading]").children(".no-collapser").addClass("collapser").removeClass("no-collapser");
      }

    });

    $('body').unbind('cocoon:after-insert').bind('cocoon:after-insert', function(event, insertedItem) {
      $(document).trigger("ornament:inline-nested:insert", [insertedItem]);
    });

  });

}(document, window, jQuery));
