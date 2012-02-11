$ = jQuery

$.fn.koiDatePicker = (opt) ->

    @datepicker @options opt,
      dateFormat: 'dd M yy',
      minDate: Date,
      maxDate: Date
