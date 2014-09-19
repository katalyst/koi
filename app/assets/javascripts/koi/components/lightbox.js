//= require magnific-popup

/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    // Single lightbox anchors
    $("[data-lightbox]").each(function(){

      var $anchor = $(this);
      var anchorType = "inline";

      // Setup lightbox options with a default type of "inline"
      var popupOptions = {
        type: "inline",
        mainClass: "lightbox--main",
        removalDelay: 300,
        callbacks: {
          open: function(){
            // callback on open to trigger a refresh for google maps
            $(document).trigger("ornament:map_refresh");
          }
        }
      }

      if($anchor.is("[data-lightbox-small]")) {
        popupOptions.mainClass = popupOptions.mainClass + " lightbox__small";
      }

      if($anchor.is("[data-lightbox-flush]")) {
        popupOptions.mainClass = popupOptions.mainClass + " lightbox__flush";
      }

      // Update type based on setting passed in to our anchor
      if($anchor.data("lightbox")) {
        popupOptions.type = $anchor.data("lightbox");
      }

      // Init magnificPopup on our anchors
      $anchor.magnificPopup(popupOptions);

    });

    // Lightbox galleries
    $("[data-lightbox-gallery]").each(function(){

      var $gallery = $(this);

      $gallery.magnificPopup({
        delegate: 'a',
        type: 'image',
        tLoading: 'Loading image #%curr%...',
        mainClass: "lightbox--main",
        removalDelay: 300,
        gallery: {
          enabled: true,
          navigateByImgClick: true,
          preload: [0,1] // Will preload 0 - before current, and 1 after the current image
        },
        image: {
          tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
        }
      });
    });

  });

  // Override Rails handling of confirmation
  $.rails.allowAction = function(element) {
    // The message is something like "Are you sure?"
    var message = element.data('confirm');

    // If there's no message, there's no data-confirm attribute, 
    // which means there's nothing to confirm
    if(!message) {
      return true;
    }

    // Clone the clicked element (probably a delete link) so we can use it in the dialog box.
    var $modalConfirm = element.clone()
      // We don't necessarily want the same styling as the original link/button.
      .removeAttr('class')
      // We don't want to pop up another confirmation (recursion)
      .removeAttr('data-confirm')
      // We want a button
      .addClass('button')
      // We want it to sound confirmy
      .html("Yes");

    var modalHtml =   '<div class="lightbox--ajax-content content-spacing">';
        modalHtml +=  '  <div class="lightbox--body">';
        modalHtml +=  '    <h2 class="heading-two lightbox--heading">'+ element.text() +'</h2>';
        modalHtml +=  '    <div class="lightbox--content  content-spacing">';
        modalHtml +=  '      <p>';
        modalHtml +=           message;
        modalHtml +=  '      </p>';
        modalHtml +=  '    </div>';
        modalHtml +=  '    <div class="lightbox--buttons">';
        modalHtml +=  '    </div>';
        modalHtml +=  '  </div>';
        modalHtml +=  '</div>';


    var $modalHtml = $(modalHtml);

    // Create our cancel button
    var $modalButtons = $modalHtml.find(".lightbox--buttons");
    var $modalCancel = $("<button class='button button__secondary'>Cancel</button>");

    // Update confirm button text
    if(element.is("[data-confirm-confirm]")) {
      $modalConfirm.text(element.attr("data-confirm-confirm"));
    }

    // Update cancel button text
    if(element.is("[data-confirm-cancel]")) {
      $modalCancel.text(element.attr("data-confirm-cancel"));
    }

    $modalButtons.append($modalCancel);
    $modalButtons.append($modalConfirm);

    // Open popup
    $.magnificPopup.open({
      mainClass: "lightbox--main",
      removalDelay: 300,
      items: {
        src: $modalHtml,
        type: 'inline'
      }
    });

    // Clicking on the cancel button hides the popup
    $modalCancel.on("click", function(e){
      $.magnificPopup.close();
      return false;
    });

    // Prevent the original link from working
    return false
  }

}(document, window, jQuery));