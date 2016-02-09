/* ==================================================

  Katalyst Image uploader script

  SOURCES:
  http://base64img.com/base64.js
  http://www.html5rocks.com/en/tutorials/file/dndfiles/
  http://www.html5rocks.com/en/tutorials/dnd/basics/
  http://blogs.sitepointstatic.com/examples/tech/filedrag/3/filedrag.js

  TODO:
  * Re-add gallery support 
  * Investigate using dragonfly style strings to 
    pass in image ratio for consistency 
  * Prevent users from leaving the page until upload has finished 

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
        browseMessage           : "Drop files here or ",
        browseMessage           : "Drop file here or ",
        undoMessage             : "Removed. Click here to undo.",
        afterInit               : function(){ return true; },
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
        var allowedArray = allowedTypes.toLowerCase().split(", ");

        var extension_split = f.name.toLowerCase().split(".");
        var extension = extension_split[extension_split.length - 1];

        debug(extension);
        debug(allowedArray);

        if( $.inArray(extension, allowedArray) > -1 ) {
          debug("matching");
          isAllowed = true;
        }

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
        var fileClasses = $thisField.attr("class") || "default";
        var $hiddenField = $("#" + $thisField.attr("data-file-for"));
        var $uploader = $thisField.closest(".file-uploader");
        var croppable = $thisField.is("[data-file-croppable]");
        var $cropModal = false;
        var $cropStringField = false;
        var jcropApi;
        var state = "idle";
        var isFile = $thisField.is("[data-file-document]");
        var imageRatio = $thisField.attr("data-file-image-ratio") || "1/1";
        var imageRatioInt = imageRatio.split("/")[0] / imageRatio.split("/")[1];

        // Image Settings
        var previewWidth = 0;
        var previewHeight = 0;
        var actualWidth = 0;
        var actualHeight = 0;
        var actualWidthDifference = 0;
        var actualHeightDifference = 0;
        var cropArea = false;
        var cropString = "";
        var tempCropString = "";

        // Demo settings
        var demoTiming = 1000;
        var demoChunks = 4;
        var demoSavingTime = 1000;

        // Gallery settings
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
        var reBindRemoveButton = function(){ return false; } 

        // Find more elements for cropping
        if(croppable) {
          // Find the modal
          $cropModal = $("#" + $thisField.attr("data-file-modal"));
          // Find the crop string field
          $cropStringField = $("#" + $thisField.attr("data-file-crop-field"));
          // Update the crop string
          var cropStringAttribute = $thisField.attr("data-file-crop-string");
          if(cropStringAttribute) {
            cropString = cropStringAttribute;
          }
        }

        // Force uncroppable on file types if developer-error
        if(isFile) {
          croppable = false;
        }

        // ===============================================
        // STATES
        // ===============================================

        var stateClasses = "idle uploading saving uploaded error";

        var setState = function(stateString) {
          debug("Setting state to: " + stateString);

          // hide everything
          $thumbnailRemove.hide();
          $messageDefault.hide();
          $messageUploading.hide();
          $messageSaving.hide();
          $messageError.hide();

          if(croppable) {
            $cropButton.hide();
          }

          // remove all classes and add one for the current state
          $dropZone.removeClass(stateClasses);
          if(stateClasses.indexOf(stateString) > -1) {
            $dropZone.addClass(stateString);
          }

          // track some flags for binding
          var removeButtonVisible = false;
          var cropButtonVisible = false;

          if(stateString === "idle") {
            $messageDefault.css("display", "inline-block");
          } else if(stateString === "uploading") {
            $messageUploading.css("display", "inline-block");
          } else if (stateString === "saving") {
            $messageSaving.css("display", "inline-block");
          } else if (stateString === "uploaded") {
            $thumbnailRemove.css("display", "inline-block");
            removeButtonVisible = true;
            if(croppable) {
              $cropButton.css("display", "inline-block");
              cropButtonVisible = true;
            }
            // positionThumbnailAfterLoad();
          } else if (stateString === "error") {
            $messageDefault.css("display", "inline-block");
            $messageError.css("display", "inline-block");
          }

          // Remove action
          if(removeButtonVisible) {
            $thumbnailRemove.off("click").on("click", function(e){
              e.preventDefault();
              // hide remove button and crop button
              $thumbnailRemove.hide();
              if(croppable) {
                $cropButton.hide();
              }
              // remove thumbnail
              $thumbnailContainer.find(".thumb").hide();
              // show default message
              $messageDefault.show();
              // remove id from field
              $hiddenField.val("");
              // remove crop string field
              if(croppable) {
                $cropStringField.val(""); 
              }
              // callback for crop etc.
              $thisField.trigger("uploader:image-removed");
              // set state for posterity
              setState("idle");
            });
          }

          // Crop action
          if(cropButtonVisible) {
            $cropButton.off("click").on("click", function(e){
              e.preventDefault();

              // Open modal
              $.magnificPopup.open({
                mainClass: "lightbox--main lightbox__cropper",
                removalDelay: 300,
                closeOnBgClick: false,
                items: {
                  type: "inline",
                  src: $cropModal
                },
                callbacks: {

                  // Resize and add crop widget when opening modal
                  open: function(){

                    // Reset image size
                    var $previewImage = $cropModal.find("[data-crop-image] > img");
                    $previewImage.height("auto").width("auto");

                    // Resize image to available space
                    var $button = $(".form--file-crop a.button__full");
                    var buttonHeight = $button.outerHeight();
                    var windowHeight = Ornament.windowHeight() * 0.8;
                    var windowWidth = Ornament.windowWidth() * 0.9;
                    var idealWindowHeight = windowHeight - buttonHeight;

                    if($previewImage.outerHeight() > idealWindowHeight) {
                      $previewImage.height(idealWindowHeight);
                    } else if($previewImage.outerHeight() > windowHeight) {
                      $previewImage.width(windowWidth);
                    }

                    // Update preview widths and actual widths
                    updateDifferences();

                    // Update crop string
                    if( $cropStringField.val() ) {
                      var dragonflyObject;
                      dragonflyObject = Ornament.uploader.dragonflyToCropObject($cropStringField.val());
                      dragonflyObject = Ornament.uploader.cropObjectToPreviewSize(dragonflyObject, actualWidthDifference, actualHeightDifference);
                      currentCrop = Ornament.uploader.getJcrop(dragonflyObject);
                    } else {
                      // initialise a default crop in the center
                      var centre = centreCoords();
                      currentCrop = [centre.x,centre.y,previewWidth,previewHeight];
                    }

                    // Initialise the crop tool
                    if(jcropApi) {
                      jcropApi = false;
                      $previewImage.next("div").remove();
                      $previewImage.show();
                    }

                    initialiseCrop($previewImage, currentCrop);

                    $thisField.trigger("uploader:modal-opened");

                    // Resize the modal to auto width
                    $(".mfp-content").width("auto");

                  },

                  // Destroy the crop widget when closing the modal
                  close: function(){
                    jcropApi.destroy();
                  }
                }
              });
            });
          }

          $thisField.trigger("uploader:state-changed", [stateString]);
        }

        $thisField.on("uploader:set-state:idle", function(){
          setState("idle");
        });

        $thisField.on("uploader:set-state:uploading", function(){
          setState("uploading");
        });

        $thisField.on("uploader:set-state:saving", function(){
          setState("saving");
        });

        $thisField.on("uploader:set-state:uploaded", function(){
          setState("uploaded");
        });

        $thisField.on("uploader:set-state:error", function(){
          setState("error");
        });

        var updateProgressBar = function(val){
          $progressBar.val(val);
          $thisField.trigger("uploader:progress-bar-updated", [ val ]);
        }

        var showError = function(message) {
          $messageError.text(message);
          setState("error");
        }

        // ===============================================
        // BUILDING MARKUP FOR A THUMBNAIL
        // ===============================================

        var createFileIcon = function(extension) {
           return '<svg viewBox="0 0 24 24" width="48" height="48">' + 
            '<polyline points="15.5,0.5 15.5,4.5 19.5,4.5 19.5,21.5 3.5,21.5 3.5,0.5 15.5,0.5 19.5,4.5" fill="none" stroke="#000000"/>' + 
            '<text x="11" y="18" font-size="7" text-anchor="middle" font-weight="bold">' + extension + '</text>' + 
          '</svg>';
        }

        // Set the width/height of the thumbnail based on the ratio
        var setThumbnailRatio = function(){
          $thumbnailContainer.attr("style", "");
          var originalWidth = $thumbnailContainer.outerWidth();
          var originalHeight = $thumbnailContainer.outerHeight();
          if(imageRatioInt > 1) {
            $thumbnailContainer.width(originalWidth * imageRatioInt);
          } else if (imageRatioInt < 1) {
            $thumbnailContainer.height(originalHeight / imageRatioInt);
          }
        }

        var createThumbnail = function(image){
          var $thumbnailContainer = $("<div class='thumbnail-container' />");
          var $imageContainer = $("<div class='thumb'><img src='" + image + "' /></div>");

          $thumbnailContainer.append($imageContainer);
          thumbnailTarget.append($thumbnailContainer);
          setThumbnailRatio();

          // return the container in case we want to do something with it after we've made it
          return $thumbnailContainer;
        }

        var createFileThumbnail = function(f){
          var name = f.name;
          var label = name; // + " (" + f.size + " bytes)";
          var extension_split = name.split(".");
          var extension = extension_split[extension_split.length - 1];

          var $thumbnailContainer = $("<div class='thumbnail-container file' />");
          // var $thumbnailRemove = $("<div class='thumbnail--remove' title='remove file'>x</div>");
          if(name.indexOf(".") < 0) {
            extension = "";
          }
          var icon = createFileIcon(extension);
          var $imageContainer = $("<div class='thumb thumb__file'><span class='thumb__file--icon'>" + icon + "</span></div>");

          $thumbnailContainer.append($imageContainer);
          // $imageContainer.append($thumbnailRemove);
          thumbnailTarget.append($thumbnailContainer);

          // return the container in case we want to do something with it after we've made it
          return $thumbnailContainer;
        }

        var createExistingThumbnail = function(url) {
          // check URL extension
          var existingName = $thisField.data("file-existing-name");
          // var urlSplit = url.split("/");
          // var filename = urlSplit[urlSplit.length-1]; // -1, array numbering and length mismatch
          var filenameSplit = existingName.split(".");
          var extension = filenameSplit[filenameSplit.length-1].toLowerCase();

          // rudamentory extension checking to see if this is an image or a document
          if(extension == "jpg" || extension == "png" || extension == "jpeg") {
            createThumbnail(url);
          } else {
            label = existingName;
            var $thumbnailContainer = $("<div class='thumbnail-container file' />");
            var icon = createFileIcon(extension);
            var $imageContainer = $("<div class='thumb thumb__file'><span class='thumb__file--icon'>" + icon + "</span></div>");
            $thumbnailContainer.append($imageContainer);
            thumbnailTarget.append($thumbnailContainer);
            // return the container in case we want to do something with it after we've made it
            return $thumbnailContainer;
          }
        }

        // ===============================================
        // CROP TOOL HELPERS
        // ===============================================

        // Get centre coords
        var centreCoords = function() {

          var x = 0;
          var y = 0;
          var offset = 0;
          var previewRatio = previewWidth / previewHeight;
          // Check if the crop ratio is higher than the ratio of the actual
          // image
          if(imageRatioInt > previewRatio) {
            // Get height of image and halve it
            // Then get height of crop area and halve that
            // Minus half crop area from half of image height to get the correct
            // position down
            if(imageRatioInt > 1) {
              offset = (previewHeight / 2) - ((previewWidth / imageRatioInt) * 0.5);
            } else {
              offset = (previewHeight / 2) - ((previewWidth * imageRatioInt) * 0.5);
            }
            y = offset;
          } else {
            // Get width of image and halve it
            // Then get width of crop area and halve that
            // Minus half crop area from half of image width to get the correct
            // position across.
            if(imageRatioInt > 1) {
              offset = (previewWidth / 2) - ((previewHeight / imageRatioInt) * 0.5);
            } else {
              offset = (previewWidth / 2) - ((previewHeight * imageRatioInt) * 0.5);
            }
            x = offset;
          }

          return { x: x, y: y };
        }

        // Get preview sizing and send the crop settings to the hidden field
        var manageCoords = function(c){
          // User has deselected a crop
          // We don't want this to happen so reset crop to center
          if(c.h === 0 && c.w === 0) {
            var centre = centreCoords();
            c.x = centre.x;
            c.y = centre.y;

            // crop width and height to match the thumbnail
            var previewRatio = previewWidth / previewHeight;
            var $thumbnail = getThumbnails();
            var thumbnailRatio = $thumbnail.outerWidth() / $thumbnail.outerHeight();
            // is preview wider than thumbnail? 
            if(previewRatio > thumbnailRatio) {
              // set to height
              c.w = previewHeight;
              c.h = previewHeight;
            } else {
              // set to width
              c.w = previewWidth;
              c.h = previewWidth;
            }

          }
          tempCropString = c;
        }

        // Calculate difference between preview and actual image size
        var updateDifferences = function(){
          var $previewImage = $cropModal.find("[data-crop-image] > img");
          previewWidth = $previewImage.outerWidth();
          previewHeight = $previewImage.outerHeight();
          actualWidth = $previewImage[0].naturalWidth;
          actualHeight = $previewImage[0].naturalHeight;
          actualWidthDifference = actualWidth / previewWidth;
          actualHeightDifference = actualHeight / previewHeight;
        }

        // Initialise crop widget on an image
        var initialiseCrop = function($image, currentCrop){
          $image.Jcrop({
            // Set our aspect ratio
            aspectRatio: imageRatioInt,
            // Set default crop area
            setSelect: currentCrop,
            // When updating crop area, handle the values for storing
            onChange: manageCoords,
            onSelect: manageCoords
          }, function(){
            jcropApi = this;
          });
        }

        // ===============================================
        // CROP MODAL CLOSE FUNCTIONALITY
        // ===============================================

        var closeCropModal = function(){
          // close popup
          $.magnificPopup.close();
          // save temp string against regular string
          var cropStringValue = Ornament.uploader.cropObjectToActualSize(tempCropString, actualWidthDifference, actualHeightDifference);
          // send to hidden field
          var dragonflyString = Ornament.uploader.getDragonflyString(cropStringValue);
          $cropStringField.val(dragonflyString);
          // Resize thumbnail
          positionThumbnail();
          $thisField.trigger("uploader:crop-set", [ dragonflyString, $cropStringField ]);
        }

        if(croppable) {
          // Pressing the close button closes the modal
          $cropModal.find("[data-crop-save]").off("click").on("click", function(e){
            e.preventDefault();
            closeCropModal();
          });
          // Trigger to close modal
          $thisField.on("uploader:close-crop-modal", function(){
            closeCropModal();
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
          // rebindOrdering();
          // updateInputOrder();
        }

        var showUndo = function(){
          thumbnailTarget.append($undoButton);
          $undoButton.off("click").on("click", function(e) {
            e.preventDefault();
            undoRemoveImage();
          });
        }

        // ===============================================
        // ALTERING FILE UPLOAD DOM
        // ===============================================

        // drop-zone container
        var $dropZone = $("<div class='file-uploader--drop-zone' />");
        var $dropZoneContainer = $("<div class='dropzone_"+fileClasses+"' />");

        // thumbnail for image
        var $thumbnailContainer = $("<div class='file-upload--thumbnail' />");

        // creating a message container for text and requirements
        var $dropZoneText = $("<div class='file-uploader--controls' />");
        var $dropZoneBrowse = $("<a href='#' class='file-upload--browse-button'>browse</a>");
        var $messageDefault = $("<span data-file-message=\"default\">"+options.browseMessage+"</span>").append($dropZoneBrowse)
        var $messageError = $("<span data-file-message=\"error\" class=\"file-uploader--error\"></span>");
        var $messageUploading = $("<span data-file-message=\"uploading\">Uploading...</span>");
        var $messageSaving = $("<span data-file-message=\"saving\">Saving...</span>");
        $dropZoneText.append($messageDefault).append($messageUploading).append($messageSaving).append($messageError);

        // creating hint message
        var $dropZoneHint = $("<div class='file-uploader--notes' />");
        if(maxSize) {
          $dropZoneHint.append("<p class='file-uploader--max-size'>Max file size: " + maxSize + "MB</p>");
        }
        if(allowedTypes) {
          $dropZoneHint.append("<p class='file-uploader--file-type'>File types allowed: " + allowedTypes+"</p>");
        }
        if(maxCount > 1) {
          $dropZoneHint.append("Maximum number of files: " + maxCount+"<br />");
        }

        // add hint text to page, either in placeholder or above dropzone
        if(options.hintPlaceholder) {
          var $thisHintPlaceholder = $thisField.closest(".input").find(options.hintPlaceholder);
          $thisHintPlaceholder.html($dropZoneHint);
        } else {
          $uploader.append($dropZoneHint);
        }

        // creating a gallery container for images in gallery mode
        var $galleryContainer = $("<div class='file-upload--gallery' />");

        // Hiding the real field, adding our markup
        $dropZoneContainer.append($dropZone);
        $thisField.hide();
        $thisField.after($dropZoneContainer);

        // adding thumbnail and message to drop zone
        // only add thumbnail if there's only one required image
        if(gallery) {
          $dropZoneContainer.prepend($galleryContainer);
          $thisField.prop("multiple", true);
        } else {
          $dropZone.append($thumbnailContainer);
          setThumbnailRatio();
        }

        $dropZone.append($dropZoneText);

        // setting where to show our images after they've been dropped
        var thumbnailTarget = $thumbnailContainer;
        if(gallery) {
          thumbnailTarget = $galleryContainer;
        }

        // create a remove button for whwen images are added
        var $thumbnailRemove = $("<a href='#' title='remove file'>Remove</a>").hide();
        $dropZoneText.append($thumbnailRemove);
        if(croppable) {
          var $cropButton = $("<a href='#' title='crop' class='file-upload--crop-button'>Crop</a>").hide();
          $thumbnailRemove.before($cropButton);
        }

        // Add existing images
        if(existingImage) {
          // $dropZoneText.find("[data-file-message]").hide();
          setState("uploaded");
          createExistingThumbnail(existingImage);
        } else {
          setState("idle");
        }

        // creating a rubbish bin and undo button for undo deletion
        var $undoButton = $("<div class='file-upload--undo'><span>"+options.undoMessage+"</span></div>");
        var $rubbishBin = $("<div class='file-upload--rubbish' />");

        // create a progress bar element for later
        var $progressBar = $("<progress value='0' max='100' />");
        $dropZone.append($progressBar);

        // ===============================================
        // GET THUMBNAIL ITEMS
        // ===============================================

        var getThumbnails = function(){
          return $thumbnailContainer.find(".thumb");
        }

        var getThumbnailImages = function(){
          return $thumbnailContainer.find(".thumb img");
        }

        // ===============================================
        // REPOSITION THUMBNAIL IN UPLOADER WIDGET
        // ===============================================

        // Position image inside thumbnail area
        var positionThumbnail = function(){
          var $thumbnail = getThumbnails();
          var $image = $thumbnail.find("img");

          if($image.length) {

            var thumbnailWidth = $thumbnail.outerWidth();
            var thumbnailHeight = $thumbnail.outerHeight();

            var thumbnailObject = {
              thumbnail: $thumbnail,
              image: $image,
              ratio: thumbnailWidth / thumbnailHeight,
              w: $thumbnail.outerWidth(),
              h: $thumbnail.outerHeight()
            };
            
            if(tempCropString !== "") {
              var cropObject = Ornament.uploader.cropObjectToActualSize(tempCropString, actualWidthDifference, actualHeightDifference);
            } else if (cropString !== "") {
              var cropObject = Ornament.uploader.dragonflyToCropObject(cropString);
            } else {
              var cropObject = {
                x: 0,
                y: 0,
                w: 0,
                h: 0,
                x2: $image.outerWidth(),
                y2: $image.outerHeight()
              }
            }

            Ornament.uploader.makeThumbnailForUploader(cropObject, thumbnailObject);

            $image.on("load", function(){
              thumbnailObject.image = $image;
              Ornament.uploader.makeThumbnailForUploader(cropObject, thumbnailObject);
            });

            debug("Positioning thumbnail");
          }
        }

        // Reposition thumbnail now AND after the image has loaded too
        var positionThumbnailAfterLoad = function(){
          positionThumbnail();
          $.each(getThumbnailImages(), function(){
            $(this).on("load", function(){
              positionThumbnail();
            });
          });
        }

        // Set a trigger to force update thumbnail if needed
        $thisField.on("uploader:update-thumbnail", function(){
          positionThumbnail();
        });

        // Reposition thumbnail by default after a toggle-change
        $(document).on("ornament:toggle-change", function(){
          positionThumbnailAfterLoad();
        });

        // Reposition thumbnail by default after a show change
        $(document).on("ornament:show-change", function(){
          positionThumbnailAfterLoad();
        });

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
          // debug(" ");
          // debug("There are currently " + getGalleryCount() + " images uploaded.");

          // debug("Gallery is not maxed yet, allowing user to keep uploading");
          // $dropZone.find(".file-uploader--controls").remove();
          // $dropZone.append($dropZoneText);
          
          // reBindBrowseButton();
        }

        // Show maxed gallery message
        // updateDropZoneIfMaxed();

        // Position thumbnail
        positionThumbnailAfterLoad();

        // Callback for adding things to the browse area
        $thisField.trigger("uploader:init");

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
                positionThumbnailAfterLoad();
                updateDropZoneIfMaxed();

              // Document thumbnail:
              } else {
                var thumbnail = createFileThumbnail(f);
                updateDropZoneIfMaxed();
              }

              // send file to server
              fd.append('file',f);

              // Reset progress bar
              updateProgressBar(0);

              if(options.demo) {

                setState("uploading");
                positionThumbnailAfterLoad();
                var demoSingleTiming = demoTiming / demoChunks;
                var progressCounter = 0;

                var progressInterval = setInterval(function(){
                  progressCounter += ( 100 / demoChunks );
                  updateProgressBar(progressCounter);
                }, demoSingleTiming);

                setTimeout(function(){
                  clearInterval(progressInterval);
                  setState("saving");
                  positionThumbnailAfterLoad();
                  if($progressBar.val() !== 100) {
                    updateProgressBar(100);
                  }
                  setTimeout(function(){
                    $hiddenField.val("12");
                    uploadFinished();
                  }, demoSavingTime);
                }, demoTiming);

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
                    $dropZone.addClass("uploading");
                    // listen for progress intervals and update bar
                    xhr.upload.addEventListener("progress", function(e){
                      var pc = parseInt(e.loaded / e.total * 100);
                      updateProgressBar(pc);
                      debug("progress updated to: " + pc);
                    }, false);
                    xhr.addEventListener("loadend", function(e){
                      setState("saving");
                    });
                    return xhr;
                  },

                  success: function(result) {
                    setTimeout(function(){
                      var oldValue = $hiddenField.val();
                      // assign received ids to input value
                      $hiddenField.val(result);
                      uploadFinished();
                    }, 200);
                  },

                  error: function(result) {
                    alert("image upload failed");
                    setTimeout(function(){
                      setState("idle");
                      $thumbnailContainer.find(".thumb").hide();
                    },200);
                  }
                });
              }

              // update orderability on new images
              if(options.orderable) {
                thumbnail.attr("draggable", true);
                rebindOrdering();
              }

              // remove thumbnail on click
              // thumbnail.find(".thumbnail--remove").on("click", function(){
              //   removeImage(thumbnail);
              // });

            };
          })(f);

          reader.readAsDataURL(f);
        }

        var uploadFinished = function(){
          
          setState("uploaded");

          // Copy the image to the crop modal
          if(croppable) {
            var $image = $thumbnailContainer.find("img");
            $cropModal.find("[data-crop-image]").html("").append($image.clone());
            // Empty out the crop string
            $cropStringField.val("");
          }

          setTimeout(function(){
            positionThumbnailAfterLoad();
          }, 400);

          // Callbacks
          $thisField.trigger("uploader:after-upload", [ $uploader,$dropZone,$cropStringField,$hiddenField ]);
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
          getInfoAboutFile(files);
          // $fileElement.files = files;
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

              // rebindOrdering();
              // updateInputOrder();

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

$(document).on("ornament:refresh", function(){

  $("[data-file-uploader]").each(function(){

    var $this = $(this);
    var isFile = $this.is("[data-file-document]");
    var isDemo = $this.is("[data-file-demo]");

    // Set upload path
    var path = "/admin/uploads/image";
    if(isFile) {
      path = "/admin/uploads/file"
    }

    // Initialise uploader
    $this.not(".file-upload__init").katFileUpload({
      uploadPath: path,
      demo: isDemo
    }).addClass("file-upload__init");

  });
});