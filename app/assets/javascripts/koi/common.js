//= require      ./jquery/browser
// require_tree ./jquery

$(function () {
  $(".datetimepicker").datetimepicker({
    stepMinute: 5,
    controlType: "select",
    timeFormat: "h:mm TT",
    dateFormat: "D, M d yy at",
  });
});
