//= require koi/clipboard

var Styleguide = Ornament.Styleguide = {};

Styleguide.addCopyLinkToCodeSample = function(container, index, value) {
  var copyBtnId = 'copy-btn-' + index.toString();
  var $button = $('<button class="sg-feature--copy" id="' + copyBtnId + '" data-copy-code>Copy</button>');
  var content = $(container).find("pre")[0];
  $(container).prepend($button);

  var clipboard = new Clipboard('#' + copyBtnId, {
    target: function(trigger) {
      return content;
    }
  });

  // Change the text of the copy button when it's clicked on
  clipboard.on('success', function(event) {
    $button.text('Copied!');
    window.setTimeout(function() {
      $button.text('Copy');
    }, 3000);
  });

  // Log errors on copy failure
  clipboard.on('error', function(event) {
      console.error('Action:', event.action);
      console.error('Trigger:', event.trigger);
  });
}

Styleguide.init = function(){
  // Adding copy links to styleguide textareas
  // Stolen from foundation's documentation 
  $('[data-styleguide-code-sample]').each(function(index, value) {
    Styleguide.addCopyLinkToCodeSample(this, index, value);
  });
}

$(document).on("ornament:refresh", function(){ 
  Styleguide.init();
});