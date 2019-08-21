/*jslint browser: true, indent: 2, todo: true, unparam: true */
/*global jQuery,Ornament /*/

(function (document, window, $) {
  "use strict";

  // Get image placeholder
  function getThumbnail(type, url, existing) {
    if (!url) {
      return false;
    }
    if (type === "document") {
      return "/assets/koi/application/icon-file-pdf.png";
    }
    if (existing) {
      // this url will redirect to the correct url, regardless of the image's actual extension
      return "/assets/" + url + ".jpg";
    }
    return url;
  }

  // Update the thumbnail placeholder markup
  function updateThumbnail($this, url) {
    var removeButton = $this.find("[data-asset-manager-remove]");
    var thumbnail = $this.find("[data-asset-manager-thumbnail]");
    var type = $this.data("asset-manager-type");

    if (url) {
      thumbnail.html("<img src='" + getThumbnail(type, url) + "' />");
      removeButton.parent().css("display", "block");
    } else {
      thumbnail.html("<div class=\"composable--asset-field--empty-image\"></div>");
      removeButton.parent().css("display", "none");
    }
  }

  // Open modal
  function startBrowsing(e) {
    e.preventDefault();
    var type = this.data("asset-manager-type");
    var assetId = this.data("asset-manager-field");
    var popupOptions = $.extend({}, Ornament.popupOptions, {
      type: "iframe",
      items: {
        src: "/admin/" + type + "s/new?callbackFunction=composableFieldImageCallback" + assetId
      }
    });
    $.magnificPopup.open(popupOptions);
  }

  // Closing modal when finishing
  function finishedBrowsing(assetId, url) {
    $.magnificPopup.close();
    var id = this.data("asset-manager-field");
    this.find("#" + id).val(assetId);
    updateThumbnail(this, url);
  }

  // Remove asset action
  function clearField(e) {
    e.preventDefault();
    var id = this.data("asset-manager-field");
    this.find("#" + id).val("");
    updateThumbnail(this);
  }

  $.fn.manageAsset = function () {
    if (this.data("asset-manager-field-loaded")) return;

    this.data("asset-manager-field-loaded", true);

    var id = this.data("asset-manager-field");
    var assetType = this.data("asset-manager-type");

    window["composableFieldImageCallback" + id] = finishedBrowsing.bind(this);

    // button bindings
    this.find("[data-asset-manager-browse]").on("click", startBrowsing.bind(this));
    this.find("[data-asset-manager-remove]").on("click", clearField.bind(this));

    return this;
  };

  var ManagedAsset = Ornament.Components.ManagedAsset = {
    init: function () {
      $("[data-asset-manager-field]").each(function () {
        $(this).manageAsset()
      });
    }
  };

  $(document).on("ornament:refresh", function () {
    ManagedAsset.init();
  });

}(document, window, jQuery));
