//= require ./_import

!function ($) {

  $.livequery.registerPlugin ("html");

  $.application.debug = true;

  // $('.tab-content').application
  //   (function ($this) { $this.children ().maximise ('height'); });

  $('.date.input').application
    (true, function ($this) { $this.koiDatePicker () });

  $('.rich.text.input').application
    (true, function ($this) { $this.koiEditor () });

  $('.sortable.fields').application
    (true, function ($this) { $this.koiSortable () });

  $('.nested-fields').application
    (true, function ($this) { $this.koiNestedFields () });

} (jQuery);
