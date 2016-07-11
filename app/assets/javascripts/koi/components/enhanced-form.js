/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:enhance-forms", function () {

    // Enhance simple_form
    $(".form--enhanced input").not(".enhanced").each(function(){
      $(this).addClass("enhanced").after("<span class='form--enhanced--control'></span>");
    });

    // jQuery Components
    if(Ornament.jQueryUISupport) {
      // Datepicker
      $("input.datepicker, .datepicker input").not(".datepicker__enabled").datepicker({
        dateFormat: 'dd/mm/yy',
        showButtonPanel: true,
        changeMonth: true,
        changeYear: true
      }).addClass("datepicker__enabled");

      // Datetime Picker
      $('input.datetimepicker, .datetimepicker input').not(".datetimepicker__enabled").datetimepicker({
        stepMinute:  5,
        controlType: 'select',
        timeFormat:  'h:mm TT',
        dateFormat:  'D, M d yy at',
        showButtonPanel: true,
        changeMonth: true,
        changeYear: true
      }).addClass("datetimepicker__enabled");
    }

    // Select2 Tagging
    $("[data-tag-input]").each(function(){
      var $tagInput = $(this);

      $tagInput.select2({
        tags: JSON.parse($tagInput.attr("data-tag-list")),
        tokenSeparators: [","," "]
      });

      $tagInput.select2("container").find("ul.select2-choices").sortable({
        containment: 'parent',
        start:  function() { $tagInput.select2("onSortStart"); },
        update: function() { $tagInput.select2("onSortEnd"); }
      });
    });

  });

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:enhance-forms");
  });

}(document, window, jQuery));