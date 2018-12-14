/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {

  "use strict";

  $(document).on("ornament:refresh", function () {

    var assetManagers = document.querySelectorAll("[data-asset-manager-field]");
    for(var i = 0; i < assetManagers.length; i++) {
      (function(){
        var assetManager = assetManagers[i];
        var id = assetManager.getAttribute("data-asset-manager-field");
        var browseButton = assetManager.querySelector("[data-asset-manager-browse]");
        var removeButton = assetManager.querySelector("[data-asset-manager-remove]");
        var hiddenField = assetManager.querySelector("#" + id);
        var thumbnail = assetManager.querySelector("[data-asset-manager-thumbnail]");
        var assetType = assetManager.getAttribute("data-asset-manager-type");
        window["composableFieldImageCallback" + id] = finishedBrowsing;

        // Get image placeholder
        function getThumbnail(url, existing) {
          if(!url) {
            return false;
          }
          if(assetType === "document") {
            return `/assets/koi/application/icon-file-pdf.png`;
          }
          if(existing) {
            // this url will redirect to the correct url, regardless of the image's actual extension
            return `/assets/${url}.jpg`;
          }
          return url;
        }

        // Update the thumbnail placeholder markup
        function updateThumbnail(url){
          if(url) {
            thumbnail.innerHTML = "<img src='" + getThumbnail(url) + "' />";
            removeButton.parentNode.style.display = "block";
          } else {
            thumbnail.innerHTML = "<div className=\"composable--asset-field--empty-image\"></div>"
            removeButton.parentNode.style.display = "none";
          }
        }

        // Open modal
        function startBrowsing(e){
          e.preventDefault();
          const popupOptions = {
            ...Ornament.popupOptions,
            type: "iframe",
            items: {
              src: "/admin/" + assetType + "s/new?callbackFunction=composableFieldImageCallback" + id
            }
          };
          $.magnificPopup.open(popupOptions);
        }

        // Closing modal when finishing
        function finishedBrowsing(assetId, url) {
          $.magnificPopup.close();
          hiddenField.value = assetId;
          updateThumbnail(url);
        }

        // Remove asset action
        function clearField(e) {
          e.preventDefault();
          hiddenField.value = "";
          updateThumbnail();
        }

        // button bindings
        browseButton.removeEventListener("click", startBrowsing);
        browseButton.addEventListener("click", startBrowsing);
        removeButton.removeEventListener("click", clearField);
        removeButton.addEventListener("click", clearField);
      }());
    }

  });

}(document, window, jQuery));