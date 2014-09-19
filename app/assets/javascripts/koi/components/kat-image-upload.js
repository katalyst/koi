/* ==================================================

  Katalyst Image uploader script

  SOURCES:
  http://base64img.com/base64.js
  http://www.html5rocks.com/en/tutorials/file/dndfiles/
  http://www.html5rocks.com/en/tutorials/dnd/basics/
  http://blogs.sitepointstatic.com/examples/tech/filedrag/3/filedrag.js

  FILE REQUIREMENTS
  * /assets/javascripts/components/kat-image-upload.js (add to application.js)
  * /assets/stylesheets/components/_kat-image-upload.css.scss (add to application.css.scss imports)
  * /views/koi/crud/_form_field_image.html.erb

================================================== */

(function($){

  $.fn.extend({
    katFileUpload: function(options) {

      // Default options
      var defaults = {
        dropzoneHoverClass      : "file-upload--dropzone--over",
        debug                   : false,
        orderable               : true,
        showMessageForOldIEs    : true,
        hintMarkup              : "<p class='hint-block'></p>",
        hintPlaceholder         : false,
        uploadPath              : "/uploads/image",
        demo                    : false, // demo mode doesn't upload anything
        browseMessage           : "Drop your file here or click browse to upload.",
        undoMessage             : "Removed. Click here to undo.",
        beforeUpload            : function(){ return true; },
        afterImageUpload        : function(){ return true; },
        afterFileUpload         : function(){ return true; },
        afterDrop               : function(){ return true; }
      }

      var options =  $.extend(defaults, options);

      // Feature Detection
      // Requires Modernizr with drag and drop and file api
      var supportsDragAndDrop = false;
      var supportsFileAPI = false;

      if (Modernizr.draganddrop === true) {
        supportsDragAndDrop = true;
      }
      if (Modernizr.filereader === true) {
        supportsFileAPI = true;
      }

      // Abort if unsupported
      if(!supportsFileAPI || !supportsDragAndDrop){
        // show flash message for unsupported browsers
        $(".file-upload-flash").show();
        return false;
      }

      // Debug function to make debugging less verbose in code
      var debug = function(text){
        if(options.debug){
          console.log(text);
        }
      }

      debug("KatFileUpload Plugin Debug Info ------------------------");
      debug("Supports Drag and Drop: " + supportsDragAndDrop);
      debug("Supports File API: " + supportsFileAPI);
      debug(" ");

      // ===============================================
      // CHECK FILE SIZE AND TYPES
      // ===============================================

      // Check the file size, returns true if under
      // returns false if the file is too big
      var checkFileSize = function(f, maxSize) {
        var sizeInBytes = f.size;
        var sizeInKilobytes = sizeInBytes / 1024;
        var sizeInMegabytes = sizeInKilobytes / 1024;

        if(sizeInMegabytes > parseFloat(maxSize)) {
          return false;
        } else {
          return true;
        }
      }

      // Check file types
      var checkFileType = function(f, allowedTypes) {
        var fileType = f.type;
        var isAllowed = false;
        var allowedArray = allowedTypes.toLowerCase().split(",");

        var extension_split = f.name.split(".");
        var extension = extension_split[extension_split.length - 1];

        debug(extension);
        debug(allowedArray);

        if( $.inArray(extension, allowedArray) > -1 ) {
          debug("matching");
          isAllowed = true;
        }

        /*

        // mime types
        var typeJpeg    = "image/jpeg";
        var typeGif     = "image/gif";
        var typePng     = "image/png";
        var typePdf     = "application/pdf";
        var typeWord    = "application/msword";
        var typeExcel   = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

        debug(" ");
        debug("checking against: " + allowedTypes);
        debug("file is: " + fileType);

        // convert single file types to an array
        if(allowedTypes.indexOf(",") == -1) {
          allowedArray = [allowedTypes.toLowerCase()];
        }

        // very basic and potentially unreliable method of checking file types
        switch(fileType) {
          case typeJpeg:
            if( $.inArray("jpg", allowedArray) > -1 ||
                $.inArray("jpeg", allowedArray) > -1 ) {
              isAllowed = true;
            }
            debug("matched against typeJpeg");
            break;
          case typeGif:
            if( $.inArray("gif", allowedArray) > -1 ) {
              isAllowed = true;
            }
            debug("matched against typeGif");
            break;
          case typePng:
            if( $.inArray("png", allowedArray)  > -1 ) {
              isAllowed = true;
            }
            debug("matched against typePng");
            break;
          case typeWord:
            if( $.inArray("doc", allowedArray)  > -1 ||
                $.inArray("docx", allowedArray) > -1 ) {
              isAllowed = true;
            }
            debug("matched against typeWord");
            break;
          case typeExcel:
            if( $.inArray("xls", allowedArray)  > -1 ||
                $.inArray("xlsx", allowedArray) > -1 ) {
              isAllowed = true;
            }
            debug("matched against typeWord");
            break;
          case typePdf:
            if( $.inArray("pdf", allowedArray) > -1 ) {
              isAllowed = true;
            }
            debug("matched against typePdf");
            break;
          default:
            debug("did not match any known mime types");
            break;
        }
        debug(" ");
        */

        return isAllowed;

      }

      // ===============================================
      // LOOP OVER EACH FILE UPLOAD FIELD
      // ===============================================
      return this.each(function() {

        // Store element
        var $fileElement = this;

        // abort if this isn't an input
        if( !$(this).is("input") ) {
          debug(" ");
          debug("aborted, called on something that isn't an input field.");
          debug("called on " + this.nodeName);
          debug(" ");
          return false;
        }

        // ===============================================
        // INTERNAL SETTINGS
        // ===============================================

        var $thisField = $(this);
        var allowedTypes = $thisField.data("file-types");
        var maxSize = $thisField.data("file-max-size");
        var maxCount = $thisField.data("file-max-count");
        var existingImage = $thisField.data("file-existing-image");
        var fileClasses = $thisField.attr("class");
        var $hiddenField = $("#"+ $thisField.attr("data-field") );

        var gallery = true;
        if(maxCount === 1) {
          gallery = false;
        }

        debug("Field Info ------------------------");
        debug("Restricted to: " + allowedTypes);
        debug("Max Size: " + maxSize);
        debug("Max Count: " + maxCount);
        debug("Gallery mode: " + gallery);
        debug(" ");

        // temprary var functions that are defined later
        var reBindBrowseButton = function(){ return false; }        

        // ===============================================
        // BUILDING MARKUP FOR A THUMBNAIL
        // ===============================================

        var createThumbnail = function(image){
          var $thumbnailContainer = $("<div class='thumbnail-container' />");
          var $thumbnailRemove = $("<div class='thumbnail--remove' title='remove file'>x</div>");
          var $imageContainer = $("<div class='thumb'><img src='"+image+"' /></div>");

          $thumbnailContainer.append($imageContainer);
          $imageContainer.append($thumbnailRemove);
          thumbnailTarget.append($thumbnailContainer);

          // remove behaviour
          $thumbnailRemove.on("click", function(){
            removeImage($thumbnailContainer);
          });

          // return the container in case we want to do something with it after we've made it
          return $thumbnailContainer;
        }

        var createFileThumbnail = function(f){
          var name = f.name;
          var label = name; // + " (" + f.size + " bytes)";
          var extension_split = name.split(".");
          var extension = extension_split[extension_split.length - 1];

          var $thumbnailContainer = $("<div class='thumbnail-container file' />");
          var $thumbnailRemove = $("<div class='thumbnail--remove' title='remove file'>x</div>");
          var $imageContainer = $("<div class='thumb'><span class='file file__"+extension+"'>"+label+"</span></div>");

          $thumbnailContainer.append($imageContainer);
          $imageContainer.append($thumbnailRemove);
          thumbnailTarget.append($thumbnailContainer);

          // remove behaviour
          $thumbnailRemove.on("click", function(){
            removeImage($thumbnailContainer);
          });

          // return the container in case we want to do something with it after we've made it
          return $thumbnailContainer;
        }

        var createExistingThumbnail = function(url) {
          // check URL extension
          var urlSplit = url.split("/");
          var filename = urlSplit[urlSplit.length-1]; // -1, array numbering and length mismatch
          var filenameSplit = filename.split(".");
          var extension = filenameSplit[filenameSplit.length-1];

          // rudamentory extension checking to see if this is an image or a document
          if(extension == "jpg" || extension == "png" || extension == "jpeg") {
            createThumbnail(url);
          } else {
            label = filename;
            var $thumbnailContainer = $("<div class='thumbnail-container file' />");
            var $thumbnailRemove = $("<div class='thumbnail--remove' title='remove file'>x</div>");
            var $imageContainer = $("<div class='thumb'><span class='file file__"+extension+"'>"+label+"</span></div>");

            $thumbnailContainer.append($imageContainer);
            $imageContainer.append($thumbnailRemove);
            thumbnailTarget.append($thumbnailContainer);

            // remove behaviour
            $thumbnailRemove.on("click", function(){
              removeImage($thumbnailContainer);
            });

            // return the container in case we want to do something with it after we've made it
            return $thumbnailContainer;
          }
        }

        // ===============================================
        // ALTERING FILE UPLOAD DOM
        // ===============================================

        // drop-zone container
        var $dropZone = $("<div class='file-upload--dropzone' />");
        var $dropZoneContainer = $("<div class='dropzone_"+fileClasses+"' />");

        // thumbnail for image
        var $thumbnailContainer = $("<div class='file-upload--thumbnail' />");

        // creating a message container for text and requirements
        var $dropZoneText = $("<div class='file-upload--message' />");
        $dropZoneBrowse = $("<a href='#' class='file-upload--browse-button button'>Browse</a>");
        $dropZoneText.append("<span>"+options.browseMessage+"</span>").append($dropZoneBrowse);

        // creating hint message
        var $dropZoneHint = $(options.hintMarkup);
        if(maxSize) {
          $dropZoneHint.append("Max file size: " + maxSize + "mb<br />");
        }
        if(allowedTypes) {
          $dropZoneHint.append("File types allowed: " + allowedTypes+"<br />");
        }
        if(maxCount > 1) {
          $dropZoneHint.append("Maximum number of files: " + maxCount+"<br />");
        }

        // add hint text to page, either in placeholder or above dropzone
        if(options.hintPlaceholder) {
          var $thisHintPlaceholder = $thisField.closest(".input").find(options.hintPlaceholder);
          $thisHintPlaceholder.html($dropZoneHint);
        } else {
          $($fileElement).before($dropZoneHint);
        }

        // adding thumbnail and message to drop zone
        // only add thumbnail if there's only one required image
        if(!gallery) {
          $dropZone.append($thumbnailContainer);
        }

        // creating a gallery container for images in gallery mode
        var $galleryContainer = $("<div class='file-upload--gallery' />");

        // Hiding the real field, adding our markup
        $dropZoneContainer.append($dropZone);
        $thisField.hide();
        $thisField.after($dropZoneContainer);
        if(gallery) {
          $dropZoneContainer.prepend($galleryContainer);
          $thisField.prop("multiple", true);
        }

        // setting where to show our images after they've been dropped
        var thumbnailTarget = $thumbnailContainer;
        if(gallery) {
          thumbnailTarget = $galleryContainer;
        }

        // Add existing images
        if(existingImage) {
          createExistingThumbnail(existingImage);
        }

        // creating a rubbish bin and undo button for undo deletion
        var $undoButton = $("<div class='file-upload--undo'><span>"+options.undoMessage+"</span></div>");
        var $rubbishBin = $("<div class='file-upload--rubbish' />");

        // ===============================================
        // COUNT FILES IN A GALLERY
        // ===============================================

        var getGalleryItems = function(){
          return thumbnailTarget.find(".thumbnail-container");
        }

        var getGalleryCount = function(){
          return getGalleryItems().length;
        }

        var updateDropZoneIfMaxed = function(){
          debug(" ");
          debug("There are currently " + getGalleryCount() + " images uploaded.");

          debug("Gallery is not maxed yet, allowing user to keep uploading");
          $dropZone.find(".file-upload--message").remove();
          $dropZone.append($dropZoneText);
          
          reBindBrowseButton();
        }
        updateDropZoneIfMaxed();

        // ===============================================
        // REMOVE IMAGE
        // ===============================================

        var removeImage = function(image) {
          // empty the rubbish bin (only 1 level of history)
          $rubbishBin.html("");
          // move deleted image to rubbish bin
          image.appendTo($rubbishBin);
          updateDropZoneIfMaxed();
          showUndo();
          updateInputOrder();
          $hiddenField.val("remove");
        }

        var rebindDeleting = function(){
          // rebind the delete function
          var $galleryItems = getGalleryItems();
          $galleryItems.each(function(){
            var $thisGalleryItem = $(this);
            $thisGalleryItem.find(".thumbnail--remove").off("click").on("click", function(e){
              e.preventDefault();
              removeImage($thisGalleryItem);
            });
          });
        }

        // ===============================================
        // UNDO REMOVAL
        // ===============================================

        var undoRemoveImage = function() {
          debug(" ");
          debug("Undoing, getting last image from rubbish bin.");
          debug("Rubbish bin contents: " + $rubbishBin.html());
          // hide undo button
          $undoButton.remove();
          // find image in rubbish bin
          // restore image to gallery or thumbnail
          $rubbishBin.find(".thumbnail-container").first().appendTo(thumbnailTarget);
          updateDropZoneIfMaxed();
          // update orderability on restored image
          rebindOrdering();
          rebindDeleting();
          updateInputOrder();
        }

        var showUndo = function(){
          thumbnailTarget.append($undoButton);
          $undoButton.off("click").on("click", function(e) {
            e.preventDefault();
            undoRemoveImage();
          });
        }

        // ===============================================
        // SEND A FILE TO STORAGE
        // ===============================================

        // Process the file, add thumbnail or file data to drop zone
        var startUpload = function(f) {

          // Recheck requirements in case it somehow tries to upload anyway

          // Check if file is too big
          if(!checkFileSize(f,maxSize)){
            $thisField.val("");
            return false;
          }

          // Check file types
          if(!checkFileType(f,allowedTypes)){
            $thisField.val("");
            return false;
          }

          // Add thumbnail to dropZone
          var reader = new FileReader();
          reader.onload = (function(theFile) {
            return function(e) {

              var fd = new FormData();
              var imageFile = f.type.match('image.*');

              // Image thumbnail:
              if (imageFile) {

                // append image to thumbnail if only one image
                // if in gallery mode, append each image to the bottom of the drop zone
                var thumbnail = createThumbnail(e.target.result);
                updateDropZoneIfMaxed();

              // Document thumbnail:
              } else {
                var thumbnail = createFileThumbnail(f);
                updateDropZoneIfMaxed();
              }

              // send file to server
              fd.append('file',f);

              // create a progress bar element for later
              var $progressBar = $("<progress value='0' total='100' />");

              if(options.demo) {
                thumbnail.append($progressBar).addClass("uploaded");
              } else {

                $.ajax({
                    type: "POST",
                    url: options.uploadPath,
                    enctype: 'multipart/form-data',
                    processData: false,
                    contentType: false,
                    data: fd,
                    xhr: function() {
                      // customising the xhr so we can add in progress
                      var xhr = new window.XMLHttpRequest();
                      // create progress bar
                      thumbnail.append($progressBar);
                      thumbnail.addClass("uploading");
                      // listen for progress intervals and update bar
                      xhr.upload.addEventListener("progress", function(e){
                        var pc = parseInt(e.loaded / e.total * 100);
                        $progressBar.val(pc);
                      }, false);
                      return xhr;
                    },
                    success: function(result) {
                      var $hiddenField = $("#"+ $($fileElement).attr("data-field") );
                      var oldValue = $hiddenField.val();
                      // assign received ids to input value
                      $hiddenField.val(oldValue + "," + result);
                      thumbnail.removeClass("uploading").addClass("uploaded");
                      // add order index to data attribute
                      thumbnail.find(".thumb").attr({
                        "data-order": thumbnail.index(),
                        "data-id": result
                      });

                      // callback after upload
                      if (imageFile) {
                        options.afterImageUpload(f,thumbnail,gallery,thumbnailTarget,$fileElement); // callback
                      } else {
                        options.afterFileUpload(f,thumbnail,gallery,thumbnailTarget,$fileElement); // callback
                      }

                    },
                    error: function(result) {
                      thumbnail.remove();
                      alert("image upload failed");
                    }
                });
              }

              // update orderability on new images
              if(options.orderable) {
                thumbnail.attr("draggable", true);
                rebindOrdering();
              }

              // remove thumbnail on click
              thumbnail.find(".thumbnail--remove").on("click", function(){
                removeImage(thumbnail);
              });

            };
          })(f);

          reader.readAsDataURL(f);
        }

        // ===============================================
        // GET INFO ABOUT A FILE AND DISPLAY ON PAGE
        // ===============================================

        var getInfoAboutFile = function(files){

          debug(files.length + " files sent to information gatherer.");

          // loop over each file
          for (var i = 0, f; f = files[i]; i++) {

            // if there's only one image needed, the user is probably
            // replacing the image when dragging and dropping, so
            // let's remove the original image.
            if(!gallery){
              thumbnailTarget.find(".thumbnail-container").remove();
            }

            // Prevent users from adding too many images
            if( (maxCount != 0 && i >= maxCount) ||
                (getGalleryCount() >= maxCount) ||
                (getGalleryCount() + i >= maxCount) ) {
              return false;
            }

            // Get info about file
            var fileName = escape(f.name);
            var fileSize = f.size; // in bytes
            var fileDateModified = f.lastModifiedDate.toLocaleDateString();
            var fileType = f.type;

            debug("File Info ------------------------");
            debug("File #" + i);
            debug("File name: " + fileName);
            debug("File type: " + fileType);
            debug("File size (bytes): " + fileSize);
            debug("File modified date: " + fileDateModified);
            debug(" ");

            // Check if file is too big
            if(!checkFileSize(f,maxSize)){
              alert("File is too big!");
              $thisField.val("");
              return false;
            }

            // Check file types
            if(!checkFileType(f,allowedTypes)){
              alert("Incorrect file type");
              $thisField.val("");
              return false;
            }

            options.beforeUpload(); // callback

            // Create thumbnail for the image and start uploading
            startUpload(f);
          }

        };

        // ===============================================
        // DRAG AND DROP
        // dragon drop
        // ===============================================

        // Drag over/out
        $dropZone.on("dragover", function(e){
          e.preventDefault();
          e.stopPropagation();
          // Explicitly show this is a copy.
          e.originalEvent.dataTransfer.dropEffect = 'copy';
          // Add hover class
          $(this).addClass(options.dropzoneHoverClass);
        });
        $dropZone.on("dragleave", function(e){
          e.preventDefault();
          e.stopPropagation();
          // Remove hover class
          $(this).removeClass(options.dropzoneHoverClass);
        });

        // Dragging a file on to the drop zone
        $dropZone.on("drop", function(e) {
          e.preventDefault();
          e.stopPropagation();
          debug("File dropped on target area.");
          // removing hover class
          $(this).removeClass(options.dropzoneHoverClass);
          // remove undo button if available
          $undoButton.remove();
          options.afterDrop(); // callback
          // get information about the file that was dropped
          var files = e.originalEvent.dataTransfer.files;
          // getInfoAboutFile(files);
          $fileElement.files = files;
        });

        // ===============================================
        // BROWSING FOR A FILE
        // lightbox with options for:
        // browse from computer, facebook, google drive, dropbox, camera
        // ===============================================
        var $body = $("body");

        // clicking on the browse button
        var reBindBrowseButton = function(){
          $dropZoneText.find(".file-upload--browse-button").off("click").on("click", function(e){
            e.preventDefault();
            // empty field val to prevent unexpected behaviour if the user tries to select
            // the same file agin
            $thisField.val("");
            // trigger default behaviour
            $thisField.click();
          });
        }
        reBindBrowseButton();

        var showBrowseModal = function(){

          var $browseModalOverlay = $("<div class='file-upload--modal-overlay' />");
          var $browseModal = $("<div class='file-upload--modal' />");
          var $browseModalClose = $("<a href='#'>Close</a>");

          $browseModal.append($browseModalClose);
          $browseModal.append("Browse local computer");

          // add modal and overlay to body
          $body.append($browseModalOverlay.append($browseModal));

          // close modal
          $browseModalClose.on("click", function(e){
            e.preventDefault();
          });

          // esc closes modal also
          $(document).keyup(function(e) {
            if (e.keyCode == 27) {
              closeBrowseModal();
            }
          });

        }

        var closeBrowseModal = function(){
          if($browseModalOverlay.length > 0) {
            $browseModalOverlay.remove();
          }
        }

        // ===============================================
        // OVER-RIDING DEFAULT FILE BEHAVIOURS
        // ie. when a user uses the browse button to send
        // a file to the file input, add to drop zone
        // instead
        // ===============================================

        $thisField.on("change", function(e){
          e.preventDefault();
          // get the files that were sent to the input
          var files = e.originalEvent.target.files;
          // send files to drag and drop behaviours
          getInfoAboutFile(files);
          // hide undo button
          $undoButton.remove();
        });

        // ===============================================
        // MAKING GALLERY ITEMS RE-ORDERABLE
        // drag and drop images to re-order them
        // ===============================================

        // update hidden input field with order from thumbnail data attrs
        var updateInputOrder = function(){
          // abort if only single image
          if(!gallery) { return false; }

          debug("updating order");

          // loop over each item and update inputs
          var $galleryItems = getGalleryItems();
          var updatedInputValue = "";

          $galleryItems.each(function(){
            var $thisGalleryItem = $(this);
            var thisGalleryId = $thisGalleryItem.find(".thumb").attr("data-id");

            // if thisGalleryId == undefined, it's an existing image
            // we need to retain that somehow

            updatedInputValue = updatedInputValue + "," + thisGalleryId;
          });

          // update hidden field with new order
          $hiddenField.val(updatedInputValue);
        }

        var rebindOrdering = function(){
          var dragSrcEl = null;

          // abort if only single image
          if(!gallery) {return false;}

          // loop over every item and bind DnD features
          var $galleryItems = getGalleryItems();
          $galleryItems.each(function(){
            var $thisGalleryItem = $(this);

            // picking up a thumbnail
            $thisGalleryItem.off("dragstart").on("dragstart", function(e){
              debug("Dragging a gallery item");
              $thisGalleryItem.addClass("dragging");
              dragSrcEl = this;
              e.originalEvent.dataTransfer.effectAllowed = "move";
              e.originalEvent.dataTransfer.setData('text/html', $(this).html());
            });

            // dropping a thumbnail
            $thisGalleryItem.off("dragover").on("dragover", function(e){
              // neccessary, allows us to drop
              if (e.preventDefault) { e.preventDefault(); }
              e.originalEvent.dataTransfer.dropEffect = 'move';
              return false;
            });

            // dragging over a thumbnail
            $thisGalleryItem.off("dragenter").on("dragenter", function(e){
              var $hoveringGalleryItem = $(this);
              $hoveringGalleryItem.addClass("dragover");
            });

            // dragging off an item
            $thisGalleryItem.off("dragleave").on("dragleave", function(e){
              var $hoveringGalleryItem = $(this);
              $hoveringGalleryItem.removeClass("dragover");
            });

            // dropping an item
            $thisGalleryItem.off("drop").on("drop", function(e){
              if (e.stopPropagation) {
                e.stopPropagation(); // Stops some browsers from redirecting.
              }

              // Don't do anything if dropping the same column we're dragging.
              if (dragSrcEl != null && dragSrcEl.innerHTML != this.innerHTML) {
                // Set the source column's HTML to the HTML of the column we dropped on.
                dragSrcEl.innerHTML = this.innerHTML;
                this.innerHTML = e.originalEvent.dataTransfer.getData('text/html');
                $galleryItems.removeClass("dragging dragover");
              }

              rebindDeleting();
              rebindOrdering();
              updateInputOrder();

              return false;
            });

            // remove the drag over class when ending a drag
            $thisGalleryItem.off("dragend").on("dragend", function(e){
              $galleryItems.removeClass("dragging dragover");
            });

          });

          $galleryItems.attr("draggable", true);
        }

        // rebind ordering on page load to bind it to existing images
        rebindOrdering();

      });

    }
  });

})(jQuery);

$(function(){
  $(".file-upload").katFileUpload({
    uploadPath: "/uploads/image"
  });
});