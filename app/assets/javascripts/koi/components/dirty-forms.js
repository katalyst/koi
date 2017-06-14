/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    var DirtyForms = Ornament.C.DirtyForms = {

      selectors: {
        forms: "form",
        cleaners: "[data-form-cleaner]"
      },

      settings: {
        debug: false,
        dialog: {
          open: function(choice, message) {
            var $stayButton = $("<button class='button__save' data-lightbox-stay />").text("Stay");
            var $leaveButton = $("<button class='button__cancel' data-lightbox-leave />").text("Leave");
            var $modalBody = $('<div class="lightbox--body">' + 
                              '  <div class="lightbox--header">' + 
                              '    <div class="lightbox--header--logo">' + 
                              '      Please confirm' + 
                              '    </div>' + 
                              '    <div class="lightbox--header--close" data-lightbox-close data-lightbox-stay title="Close">' + 
                              '      ' + Ornament.icons.close + 
                              '    </div>' + 
                              '  </div>' + 
                              '  <div class="lightbox--content">' + 
                              '    <div class="panel--padding">' + 
                              '    ' + message + 
                              '    </div>' + 
                              '  </div>' + 
                              ' <div class="lightbox--footer">' + 
                              '   <div class="button-group" data-lightbox-buttons></div>' + 
                              ' </div>' + 
                              '</div>');
            $modalBody.find("[data-lightbox-buttons]").append($("<div>").append($stayButton))
                                                      .append($("<div>").append($leaveButton));
            var popupOptions = $.extend(true, Ornament.popupOptions, {});
            popupOptions.closeOnBgClick = false;
            popupOptions.mainClass = popupOptions.mainClass + " lightbox__small";
            popupOptions.items = {
              src: $modalBody
            };
            choice.staySelector = ".mfp-content [data-lightbox-stay]";
            choice.proceedSelector = ".mfp-content [data-lightbox-leave]";
            $.magnificPopup.open(popupOptions);
          },
          close: function(){
            $.magnificPopup.close();
          }
        }
      },

      _cleanFormEvent: function(){
        $('form:dirty').dirtyForms('setClean');
      },

      init: function(){
        DirtyForms.$forms = $(DirtyForms.selectors.forms);
        DirtyForms.$forms.each(function(){
          $(this).dirtyForms(DirtyForms.settings);
        });
        DirtyForms.$cleaners = $(DirtyForms.selectors.cleaners);
        DirtyForms.$cleaners.each(function(){
          $(this).off("click", DirtyForms._cleanFormEvent).on("click", DirtyForms._cleanFormEvent);
        });
      }
    }

    DirtyForms.init();
  });

}(document, window, jQuery));