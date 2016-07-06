Ornament = window.Ornament = {

  externalLinkExtensions: [],
  internalLinkSelectors: [],

  popupOptions: {
    type: "inline",
    mainClass: "lightbox--main",
    removalDelay: 300,
    fixedContentPos: true,
    showCloseBtn: false,
    callbacks: {
      open: function(){
        var mfp = this;
        var $anchor = $(mfp.ev.context);

        // resize to viewport
        if(!$anchor.attr("data-lightbox") === "ajax") {
          Ornament.sizeLightboxToViewport(mfp);
        }

        // Add class for lightbox open to body
        $("body").addClass("lightbox-open");

        // Add arrows to lightbox navigation
        mfp.contentContainer.find(".lightbox--navigation li a").not(".lightbox--navigation--link").each(function(){
          $(this).append(Ornament.icons.arrowSmall);
        }).addClass("lightbox--navigation--link");

        // callback on open to trigger a refresh for google maps
        $(document).trigger("ornament:map_refresh");
      },
      close: function(){
        var $anchor = $(this.ev.context);
        $("body").removeClass("lightbox-open");
      },
      resize: function(){
        // Resize to viewport
        Ornament.sizeLightboxToViewport(this);
      }
    }
  },

  // Size a specific lightbox to the screen
  sizeLightboxToViewport: function(mfp){
    if(mfp.items && mfp.items[0] && mfp.items[0].inlineElement) {
      var $lightboxBody = mfp.items[0].inlineElement;
    } else {
      var $lightboxBody = mfp.contentContainer;
    }
    var $lightboxContent = $lightboxBody.find(".lightbox--body");
    var $lightboxHeader = $lightboxBody.find(".lightbox--header");
    var topOffset = 20;
    var bottomOffset = 20;
    var windowHeight = Ornament.windowHeight();
    var maxLightboxHeightInPixels = (windowHeight - topOffset - bottomOffset) - $lightboxHeader.outerHeight();
    $lightboxContent.height("auto");

    if($lightboxContent.outerHeight() >= maxLightboxHeightInPixels) {
      $lightboxContent.height(maxLightboxHeightInPixels);
    }
  },

  // Size all lightboxes to the screen
  globalLightboxSizing: function(){
    var currentLightboxElement = $.magnificPopup.instance;
    if (currentLightboxElement.currItem) {
      Ornament.sizeLightboxToViewport(currentLightboxElement);
    }
  },

  icons: {}

};

$(document).on("ornament:refresh", function(){
  Ornament.icons.chevron = $("[data-ornament-icon-chevron]").html();
  Ornament.icons.plus = $("[data-ornament-icon-plus]").html();
  $("[data-ornament-icons]").remove();
});
