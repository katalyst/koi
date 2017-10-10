(function($) {
  $(function(){

    // https://stackoverflow.com/questions/20658402/internet-explorer-issue-with-html5-form-attribute-for-button-element
    // detect if browser supports this
    var sampleElement = $('[form]').get(0);
    var isIE11 = !(window.ActiveXObject) && "ActiveXObject" in window;
    if (sampleElement && window.HTMLFormElement && sampleElement.form instanceof HTMLFormElement && !isIE11) {
      // browser supports it, no need to fix
      return;
    }

    $("body").on("click", "button[form]", function(e){
      var $element = $(this);
      var $form = $("#" + $element.attr("form"));
      $form.submit();
    });
  });
})(jQuery);