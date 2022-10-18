//= require koi/magnific-popup

/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  $(document).on("ornament:lightbox", function () {
    // Single lightbox anchors
    $("[data-lightbox]").each(function () {
      var $anchor = $(this);
      var anchorType = "inline";

      // Setup lightbox options with a default type of "inline"
      var popupOptions = $.extend({}, Ornament.popupOptions);

      if ($anchor.is("[data-lightbox-small]")) {
        popupOptions.mainClass = popupOptions.mainClass + " lightbox__small";
      }

      if ($anchor.is("[data-lightbox-flush]")) {
        popupOptions.mainClass = popupOptions.mainClass + " lightbox__flush";
      }

      if ($anchor.is("[data-lightbox-gallery]")) {
        popupOptions.gallery = {
          enabled: true,
        };
      }

      // Update type based on setting passed in to our anchor
      if ($anchor.data("lightbox")) {
        popupOptions.type = $anchor.data("lightbox");

        if (
          $anchor.data("lightbox") === "iframe" ||
          $anchor.data("lightbox") === "image"
        ) {
          popupOptions.showCloseBtn = true;
          popupOptions.mainClass = popupOptions.mainClass +=
            " lightbox__with-close";
        }
      }

      // Init magnificPopup on our anchors
      $anchor.magnificPopup(popupOptions);
    });

    $("[data-lightbox-close]").on("click", function (e) {
      e.preventDefault();
      $.magnificPopup.close();
    });

    $(document).delegate("[data-lightbox-close]", "click", function (e) {
      e.preventDefault();
      $.magnificPopup.close();
    });
  });

  // Override Rails handling of confirmation
  $.rails.allowAction = function (element) {
    // The message is something like "Are you sure?"
    var message = element.data("confirm");

    // If there's no message, there's no data-confirm attribute,
    // which means there's nothing to confirm
    if (!message) {
      return true;
    }

    // Over-ride this functionality to return to regular rails
    // function
    if (element.is("[data-confirm-no-override]")) {
      return confirm(message);
    }

    // Clone the clicked element (probably a delete link) so we can use it in the dialog box.
    var $modalConfirm = element
      .clone()
      // We don't necessarily want the same styling as the original link/button.
      .removeAttr("class")
      // We don't want to pop up another confirmation (recursion)
      .removeAttr("data-confirm")
      // We want a button
      .addClass("button__confirm")
      // We want it to sound confirmy
      .html("Yes");

    // Create buttons
    var $modalCancel = $(
      "<button class='button button__cancel'>Cancel</button>"
    );

    // Update confirm button text
    if (element.is("[data-confirm-confirm]")) {
      $modalConfirm.text(element.attr("data-confirm-confirm"));
    }

    // Update cancel button text
    if (element.is("[data-confirm-cancel]")) {
      $modalCancel.text(element.attr("data-confirm-cancel"));
    }

    var modalHtml = $(
      '<div class="lightbox--body">' +
        '  <div class="lightbox--header">' +
        '    <div class="lightbox--header--logo">' +
        "      Please confirm" +
        "    </div>" +
        '    <div class="lightbox--header--close" data-lightbox-close title="Close">' +
        "      " +
        Ornament.icons.close +
        "    </div>" +
        "  </div>" +
        '  <div class="lightbox--content">' +
        '    <div class="panel--padding">' +
        "    " +
        message +
        "    </div>" +
        "  </div>" +
        ' <div class="lightbox--footer" data-lightbox-buttons></div>' +
        "</div>"
    );

    modalHtml
      .find("[data-lightbox-buttons]")
      .append($modalConfirm)
      .append(" ")
      .append($modalCancel);

    var openConfirmModal = function () {
      // Open popup
      var popupOptions = $.extend({}, Ornament.popupOptions);
      popupOptions.items = {
        src: modalHtml,
      };
      $.magnificPopup.open(popupOptions);
    };

    // Check if there's an existing modal
    var currentModal = $.magnificPopup.instance.currItem;
    if (currentModal) {
      var previousModal = currentModal.src;
      $.magnificPopup.close();

      setTimeout(function () {
        openConfirmModal();
      }, Ornament.popupOptions.removalDelay);
    } else {
      openConfirmModal();
    }

    // Clicking on the cancel button hides the popup
    $modalCancel.on("click", function (e) {
      $.magnificPopup.close();

      if (previousModal) {
        var popupOptions = $.extend({}, Ornament.popupOptions);
        popupOptions.items = {
          src: previousModal,
        };
        setTimeout(function () {
          $.magnificPopup.open(popupOptions);
        }, Ornament.popupOptions.removalDelay);
      }

      return false;
    });

    // Prevent the original link from working
    return false;
  };

  $(document).on("ornament:refresh", function () {
    $(document).trigger("ornament:lightbox");
  });
})(document, window, jQuery);
