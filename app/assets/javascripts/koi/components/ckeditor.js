/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {  
    // $(document).trigger("ornament:ck-editor");
  });

  $(document).on("ornament:tab-change", function () {  
    $(document).trigger("ornament:ck-editor");
  });

  $(document).on("ornament:ck-editor", function () {

    $.each(CKEDITOR.instances, function(){
      var instance = CKEDITOR.instances[$(this)[0]];
      if(instance) {
        instance.destroy(true);
      }
    });

    $ ('.wysiwyg.source').each(function() {
      // FIXME: Duplicated in wysiwyg.js
      CKEDITOR.replace (this);
    });

  });

}(document, window, jQuery));