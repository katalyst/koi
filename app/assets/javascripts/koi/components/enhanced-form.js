/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  var FormHelpers = Ornament.Components.FormHelpers = {

    enhanceForms: function(){
      // Enhance simple_form
      $(".form--enhanced input").not(".enhanced").each(function(){
        $(this).addClass("enhanced").after("<span class='form--enhanced--control'></span>");
      });
    },

    tagifyInputs: function(){
      $("[data-tag-input]").each(function(){
        var $tagInput = $(this);

        // Abort this iteration if already select2
        if($tagInput.data("select2")) {
          return true;
        }

        var select2options = {
          tokenSeparators: [","," "]
        };

        if($tagInput.is("[data-tag-list]")) {
          select2options.tags = JSON.parse($tagInput.attr("data-tag-list"));
        }

        $tagInput.select2(select2options);
        $tagInput.select2("container").find("ul.select2-choices").sortable({
          containment: 'parent',
          start:  function() { $tagInput.select2("onSortStart"); },
          update: function() { $tagInput.select2("onSortEnd"); }
        });
      });
    },

    // Build settings from a field
    _buildDatepickerSettingsForField: function($field, defaultSettings) {
      defaultSettings = defaultSettings || {};
      // List of settings we can check against
      var settingsToCheck = [
        "dateFormat", 
        "yearRange",
        "timeFormat",
        "showButtonPanel", 
        "changeMonth",
        "changeYear",
        "stepMinute",
        "controlType",
        "showButtonPanel",
      ];
      // Loop over the array of options above and over-write 
      // the default settings with the new ones
      $.each(settingsToCheck, function(){
        var attribute = "data-datepicker-" + this.toLowerCase();
        if($field.is("[data-datepicker-" + attribute + "]")) {
          defaultSettings[this] = $field.attr(attribute);
        }
      });
      return defaultSettings;
    },

    bindDatepickers: function(){

      // Default JQuery UI Settings
      var datePickerSettings = {
        dateFormat: 'dd/mm/yy',
        showButtonPanel: true,
        changeMonth: true,
        changeYear: true
      };

      var dateTimePickerSettings = {
        stepMinute:  5,
        controlType: 'select',
        timeFormat:  'h:mm TT',
        dateFormat:  'D, M d yy at',
        showButtonPanel: true,
        changeMonth: true,
        changeYear: true
      };

      // jQuery Components
      if(Ornament.jQueryUISupport) {
        // Datepicker
        $("input.datepicker, .datepicker input").not(".datepicker__enabled").each(function(){
          var $datepicker = $(this);
          var settings = FormHelpers._buildDatepickerSettingsForField($datepicker, datePickerSettings);
          $datepicker.datepicker().addClass("datepicker__enabled");
        });

        // Datetime Picker
        $('input.datetimepicker, .datetimepicker input').not(".datetimepicker__enabled").each(function(){
          var $datepicker = $(this);
          var settings = FormHelpers._buildDatepickerSettingsForField($datepicker, dateTimePickerSettings);
          $datepicker.datetimepicker(settings).addClass("datetimepicker__enabled");
        });
      }
    },

    init: function(){
      FormHelpers.enhanceForms();
      FormHelpers.tagifyInputs();
      FormHelpers.bindDatepickers();
    }

  };

  $(document).on("ornament:enhance-forms", function () {
    FormHelpers.init();
  });

  $(document).on("ornament:refresh", function () {
    FormHelpers.init();
  });

}(document, window, jQuery));