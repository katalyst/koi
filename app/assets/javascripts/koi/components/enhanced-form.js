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
        // jQueryUI Datepicker Options
        // http://api.jqueryui.com/datepicker/
        "appendText",
        "autoSize",
        "changeMonth",
        "changeYear",
        "closeText",
        "contrainInput",
        "currentText",
        "dateFormat", 
        "dayNames",
        "dayNamesMin",
        "dayNamesShort",
        "defaultDate",
        "duration",
        "firstDay",
        "gotoCurrent",
        "hideIfNoPrevNext",
        "maxDate",
        "minDate",
        "monthNames",
        "monthNamesShort",
        "navigationAsDateFormat",
        "nextText",
        "prevText",
        "selectOtherMonths",
        "shortYearCutoff",
        "showAnim",
        "showButtonPanel", 
        "showCurrentAtPos",
        "showMonthAfterYear",
        "showOptions",
        "showOtherMonths",
        "showWeek",
        "stepMonths",
        "weekHeader",
        "yearRange",
        "yearSuffix",
        // jQueryUI Datetimepicker Options
        // http://trentrichardson.com/examples/timepicker/
        "amNames",
        "pmNames",
        "timeFormat",
        "timeSuffix",
        "timeOnlyTitle",
        "timeText",
        "hourText",
        "minuteText",
        "secondText",
        "millisecText",
        "microsecText",
        "timezoneText",
        "controlType",
        "showHour",
        "showMinute",
        "showSecond",
        "showMillisec",
        "showMicroset",
        "showTimezone",
        "showTime",
        "stepHour",
        "stepMinute",
        "stepSecond",
        "stepMillisec",
        "stepMicrosec",
        "hour",
        "minute",
        "second",
        "millisec",
        "microsec",
        "timezone",
        "hourMin",
        "minuteMin",
        "secondMin",
        "millisecMin",
        "microsecMin",
        "hourGrid",
        "minuteGrid",
        "secondGrid",
        "millisecGrid",
        "microsecGrid",
        "timeInput",
        "timeOnly",
        "timeOnlyShowDate",
        "seperator",
        "pickerTimeFormat",
        "pickerTimeSuffix",
        "showTimepicker",
        "defaultValue",
        "minTime",
        "maxTime"
      ];
      // Loop over the array of options above and over-write 
      // the default settings with the new ones
      $.each(settingsToCheck, function(){
        var attribute = "data-datepicker-" + this.toLowerCase();
        if($field.is("[" + attribute + "]")) {
          var value = $field.attr(attribute);
          if(value === "true") {
            value = true;
          } else if (value === "false") {
            value = false;
          } else if (!isNaN(parseInt(value))) {
            value = parseInt(value);
          }
          defaultSettings[this] = value;
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
          $datepicker.datepicker(settings).addClass("datepicker__enabled");
        });

        // Datetime Picker
        $('input.datetimepicker, .datetimepicker input').not(".datetimepicker__enabled").each(function(){
          var $datepicker = $(this);
          var settings = FormHelpers._buildDatepickerSettingsForField($datepicker, dateTimePickerSettings);
          $datepicker.datetimepicker(settings).addClass("datetimepicker__enabled");
        });
      }
    },

    bindColourPickers: function(){
      $("[data-colourpicker]").minicolors();
    },

    isLinkAButton: function(element) {
      return element.is(".button") || 
             element.is(".button__small") || 
             element.is(".button__save") || 
             element.is(".button__delete");
    },

    disableLink: function(event){
      var target = $(event.target);
      var className = FormHelpers.isLinkAButton(target) ? "button__icon" : "link-disabled";
      target.html(Ornament.icons.spinner).addClass(className);
    },

    enableLink: function(event) {
      var target = $(event.target);
      var className = FormHelpers.isLinkAButton(target) ? "button__icon" : "link-disabled";
      target.removeClass(className);
    },

    bindCustomDisableLinks: function(){
      $("a[data-disable-with]").each(function () {
        var element = $(this);
        element.off("ajax:before", FormHelpers.disableLink).on("ajax:before", FormHelpers.disableLink);
        element.off("ajax:complete", FormHelpers.enableLink).on("ajax:complete", FormHelpers.enableLink);
      });
    },

    init: function(){
      FormHelpers.enhanceForms();
      FormHelpers.tagifyInputs();
      FormHelpers.bindDatepickers();
      FormHelpers.bindCustomDisableLinks();
      FormHelpers.bindColourPickers();
    }

  };

  $(document).on("ornament:enhance-forms", function () {
    FormHelpers.init();
  });

  $(document).on("ornament:refresh", function () {
    FormHelpers.init();
  });

}(document, window, jQuery));