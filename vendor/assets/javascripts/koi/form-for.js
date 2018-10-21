(function($) {
  $(function(){
    // https://stackoverflow.com/questions/20658402/internet-explorer-issue-with-html5-form-attribute-for-button-element
    // detect if browser supports this
    $("body").on("click", "button[form]", function(e){
      var $element = $(this);
      var sampleElement = this;
      if (sampleElement && window.HTMLFormElement && sampleElement.form instanceof HTMLFormElement) {
        // browser supports it, no need to fix
        return;
      }
      var $form = $("#" + $element.attr("form"));
      $form.submit();
    });
  });
})(jQuery);
