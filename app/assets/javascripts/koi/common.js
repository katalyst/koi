//= require      ./jquery/browser
// require_tree ./jquery
//= require koi/etc/ZeroClipboard.js

ZeroClipboard.setMoviePath ('/assets/ZeroClipboard.swf')

$ (document).on ('click', 'a[target=_clipboard]', function ()
{
  // return false
})

$(function(){
  $('.datetimepicker').datetimepicker({
    stepMinute:  5,
    controlType: 'select',
    timeFormat:  'h:mm TT',
    dateFormat:  'D, M d yy at'
  });
});