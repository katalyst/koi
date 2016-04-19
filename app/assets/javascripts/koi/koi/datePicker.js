! function ($)
{
  $.fn.koiDatePicker = function (opt)
  {
    opt || (opt = {})

    var $this = $ (this), data = $this.data ()

    opt.dateFormat = 'dd M yy'
    if (data.minDate) opt.minDate = Date (data.minDate)
    if (data.maxDate) opt.maxDate = Date (data.maxDate)

    this.datepicker (opt)
  }
} (jQuery)

$(document).on("ornament:refresh", function(){
  
  if($(".input.date").length) {
    $(".input.date").koiDatePicker();
  }
  
});