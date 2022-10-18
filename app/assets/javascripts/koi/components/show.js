/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:refresh", function () {
    // Settings
    var $showListeners, controlSeperator;
    $showListeners = $("[data-show]");
    controlSeperator = "_&_";

    var destroyData = function ($field) {
      $field.find("input").each(function () {
        var $input = $(this);
        if ($input.is("[type=checkbox]") || $input.is("[type=radio]")) {
          $input.prop("checked", false);
        } else {
          $input.val("");
        }
      });
      $field.find("textarea").each(function () {
        $(this).val("");
      });
      $field.find("select").each(function () {
        $(this).val("");
      });
    };

    // Show or hide the field
    var showHideField = function ($field, showField, instant) {
      instant = instant || false;

      // apply inverse filter
      if ($field.is("[data-show-inverse]")) {
        showField = !showField;
      }

      // show/hide field
      if (showField) {
        if (instant == true) {
          $field.show();
        } else {
          $field.slideDown("fast");
        }
      } else {
        if (instant == true) {
          $field.hide();
        } else {
          $field.slideUp("fast");
          if ($field.is("[data-show-destroy]")) {
            destroyData($field);
          }
        }
      }
    };

    // Check for select matches
    var showHideCheckSelect = function ($target, $field, instant) {
      var showField = false;
      instant = instant || false;

      if ($target.val() == $field.attr("data-show-option")) {
        showField = true;
      } else {
        showField = false;
      }

      showHideField($field, showField, instant);
    };

    // Check for radio or checkboxes
    var showHideCheckRadio = function ($target, $field, instant) {
      var showField = false;
      instant = instant || false;

      // check if radio element is checked
      if ($target.prop("checked") === true) {
        showField = true;
      } else {
        showField = false;
      }

      showHideField($field, showField, instant);
    };

    // Check for multiple radio or checkboxes
    var showHideCheckMultipleRadio = function ($field, $showTargets, instant) {
      instant = instant || false;

      var showField = false;
      var numberOfTargets = $showTargets.length;
      var numberOfTargetsHit = 0;

      // loop through all controls
      $.each($showTargets, function () {
        var $thisTarget = $(this);
        if ($thisTarget.prop("checked") === true) {
          numberOfTargetsHit++;
        }
      });

      // match any or all?
      if ($field.data("show-type") == "any") {
        if (numberOfTargetsHit > 0) {
          showField = true;
        } else {
          showField = false;
        }
      } else {
        if (numberOfTargetsHit == numberOfTargets) {
          showField = true;
        } else {
          showField = false;
        }
      }

      showHideField($field, showField, instant);
    };

    // check for input changes
    var showHideCheckInput = function ($target, $field, instant) {
      var showField = false;
      instant = instant || false;

      // check against the required value
      var valueToMatch = $field.data("show-input").toLowerCase();
      var valueLower = $target.val().toLowerCase();
      var showType = $field.data("show-type");

      // Exact vs Relative matching
      if (showType == "any") {
        // Relative matching
        // ie. "hello" matches for "hello world"
        if (valueLower.indexOf(valueToMatch) > -1) {
          showField = true;
        } else {
          showField = false;
        }
      } else {
        // Exact matching
        if (valueLower == valueToMatch) {
          showField = true;
        } else {
          showField = false;
        }
      }

      showHideField($field, showField, instant);
    };

    // Show or hide everything that has [data-show]
    var showHideAllFields = function () {
      $showListeners.each(function () {
        var $thisField,
          $showTargets,
          $siblingTargets,
          $showOnControls,
          showOn,
          multipleControls;

        $thisField = $(this);
        showOn = $thisField.data("show");
        multipleControls = false;
        $showTargets = [];

        // Create an array of required targets
        // Split on the control seperator
        if (showOn.indexOf(controlSeperator) > -1) {
          multipleControls = true;
          $showOnControls = showOn.split(controlSeperator);
        } else {
          $showOnControls = [showOn];
        }

        // Build the array
        $.each($showOnControls, function () {
          $showTargets.push($("#" + this));
        });

        // Count the number of required fields
        var numberOfTargets = $showTargets.length;
        var numberOfTargetsHit = 0;

        // Loop through each of the targets
        $.each($showTargets, function () {
          var $showTarget = $(this);
          var targetTrue = false;

          // Radios and Checkboxes
          if (
            $showTarget.is("input[type=radio]") ||
            $showTarget.is("input[type=checkbox]")
          ) {
            $siblingTargets = $("[name='" + $showTarget.attr("name") + "']");
            // check on target change
            $siblingTargets.on("change", function () {
              if (multipleControls) {
                showHideCheckMultipleRadio($thisField, $showTargets);
              } else {
                showHideCheckRadio($showTarget, $thisField);
              }
            });
            // check on page load
            if (multipleControls) {
              showHideCheckMultipleRadio($thisField, $showTargets, true);
            } else {
              showHideCheckRadio($showTarget, $thisField, true);
            }
            // Text Inputs
          } else if ($thisField.data("show-input") !== undefined) {
            // check on input update
            $showTarget.on("keyup", function () {
              showHideCheckInput($showTarget, $thisField);
            });
            // check on page load
            showHideCheckInput($showTarget, $thisField, true);
            // Select Elements
          } else if ($thisField.data("show-option") !== undefined) {
            // check on select change
            $showTarget.on("change", function () {
              showHideCheckSelect($showTarget, $thisField);
            });
            // check on page load
            showHideCheckSelect($showTarget, $thisField, true);
          }
        });
      });
    };

    // show/hide all fields on page load
    showHideAllFields();
  });
})(document, window, jQuery);
