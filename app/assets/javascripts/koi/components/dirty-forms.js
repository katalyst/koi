/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament */

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function(){

    // Warn users about leaving the page with a dirty form
    var DirtyForms = Ornament.C.DirtyForms = {
      ready: false,
      isDirty: false,
      bindingsToWatch: "change, keyup",
      message: 'Warning: There are unsaved changes.',
      forceClean: false,

      // Changing any form on the page will mark forms as dirty
      _bindDirtyFormChecker: function(){
        DirtyForms.$forms.on(DirtyForms.bindingsToWatch, function(){
          DirtyForms.isDirty = true;
        });
      },

      // Clicking on designated cleaner buttons with the attribute of 
      // data-form-cleaner will mark the forms as clean again
      _bindFormCleaners: function(){
        DirtyForms.$cleaners.on("click", DirtyForms.cleanForms);
      },

      _windowLeaveEvent: function(){
        console.log("window leave event");
        if(!DirtyForms.forceClean && DirtyForms.anyDirtyForms()) {
          return confirm(DirtyForms.message);
        }
      },

      // Check if any CKEditors are dirty
      anyCKEditorsDirty: function(){
        for (var i in CKEDITOR.instances) {
          if(CKEDITOR.instances[i].checkDirty()) {
            return true;
          }
        }
      },

      // Force disabling of dirty checker
      // Used when leaving the page via a save method
      cleanForms: function() {
        DirtyForms.forceClean = true;
      },

      // Check if CKEditor or our internal checker are dirty
      anyDirtyForms: function(){
        return DirtyForms.anyCKEditorsDirty() || DirtyForms.isDirty;
      },

      init: function(){
        // Get our elements
        DirtyForms.$forms = $("form");
        DirtyForms.$cleaners = $("[data-form-cleaner]");
        // Bind those elements
        DirtyForms._bindDirtyFormChecker();
        DirtyForms._bindFormCleaners();
        // Set a beforeunload function to warn the user if forms are dirty
        // and they try to leave the page. 
        if(DirtyForms.$forms.length) {
          if(!DirtyForms.ready) {
            DirtyForms.ready = true;
            if(Ornament.features.turbolinks) {
              $(document).off("turbolinks:before-visit", DirtyForms._windowLeaveEvent)
                         .on("turbolinks:before-visit", DirtyForms._windowLeaveEvent);
            } else {
              $(window).bind('beforeunload', DirtyForms._windowLeaveEvent);
            }
          }
        }
      }
    }

    DirtyForms.init();

  });

}(document, window, jQuery));
