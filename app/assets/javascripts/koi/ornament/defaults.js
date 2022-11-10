Ornament = window.Ornament = {

  Components: {},

  jQueryUISupport: true,

  popupOptions: {
    type: "inline",
    mainClass: "lightbox--main",
    removalDelay: 300,
    fixedContentPos: true,
    showCloseBtn: false,
    callbacks: {
      beforeOpen: function(){
        window.mfpScrollPosition = $(document).scrollTop();
      },
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

        if(window.mfpScrollPosition) {
          $(".layout").css({
            position: "relative",
            top: window.mfpScrollPosition * -1
          });
        }

        Ornament.popupOpened(true);
      },
      close: function(){
        var $anchor = $(this.ev.context);
        $("body").removeClass("lightbox-open");

        if(window.mfpScrollPosition) {
          $(".layout").css({
            position: "static",
            top: 0
          });
          scrollTo(0, window.mfpScrollPosition);
        }
      },
      resize: function(){
        // Resize to viewport
        Ornament.sizeLightboxToViewport(this);
      },
      change: function() {
        setTimeout(function(){
          Ornament.popupOpened(true);
        }, 10);
      }
    }
  },

  popupOpened: function(resize){
    resize = resize || false;
    $(document).trigger("ornament:tabs");
    $(document).trigger("ornament:toggles");
    $(document).trigger("ornament:enhance-forms");
    $(document).trigger("ornament:map_refresh");
    if(resize) {
      Ornament.globalLightboxSizing();
    }
  },

  showHideXYShadows: function($element) {
    var scrollTop = $element.scrollTop();
    var maxScroll = 0;
    $element.children().each(function(){
      maxScroll += parseInt($(this).outerHeight());
    });
    maxScroll = maxScroll - $element.outerHeight();

    var showTopShadow = false;
    var showBottomShadow = false;
    var $topShadow = $element.parent().find("[data-shadow-top]");
    var $bottomShadow = $element.parent().find("[data-shadow-bottom]");

    if(scrollTop != 0) {
      showTopShadow = true;
    }

    if(scrollTop < maxScroll) {
      showBottomShadow = true;
    }

    if(showTopShadow) {
      $topShadow.show();
    } else {
      $topShadow.hide();
    }

    if(showBottomShadow) {
      $bottomShadow.show();
    } else {
      $bottomShadow.hide();
    }
  },

  // Size a specific lightbox to the screen
  sizeLightboxToViewport: function(mfp){
    if(mfp.items && mfp.items[0] && mfp.items[0].inlineElement) {
      var $lightboxBody = mfp.items[0].inlineElement;
    } else {
      var $lightboxBody = mfp.contentContainer;
    }
    var $lightboxContent = $lightboxBody.find(".lightbox--content");
    var $lightboxHeader = $lightboxBody.find(".lightbox--header");
    var $lightboxFooter = $lightboxBody.find(".lightbox--footer");
    var topOffset = 20;
    var bottomOffset = 20;
    var windowHeight = Ornament.windowHeight();
    var scrollPosition = $lightboxContent.scrollTop() || 0;
    var maxLightboxHeightInPixels = (windowHeight - topOffset - bottomOffset) - $lightboxHeader.outerHeight() - $lightboxFooter.outerHeight();
    $lightboxContent.height("auto");

    if($lightboxContent.outerHeight() >= maxLightboxHeightInPixels) {
      $lightboxContent.height(maxLightboxHeightInPixels);
    }

    Ornament.showHideXYShadows($lightboxContent);
    $lightboxContent.off("scroll").on("scroll", function(){
      Ornament.showHideXYShadows($lightboxContent);
    });

    $lightboxContent.scrollTop(scrollPosition);
  },

  // Size all lightboxes to the screen
  globalLightboxSizing: function(){
    var currentLightboxElement = $.magnificPopup.instance;
    if (currentLightboxElement.currItem) {
      Ornament.sizeLightboxToViewport(currentLightboxElement);
    }
  },

  // Fuzzysearch
  // https://github.com/bevacqua/fuzzysearch/blob/master/index.js
  fuzzySearch: function(needle, haystack){
    var hlen = haystack.length;
    var nlen = needle.length;
    if (nlen > hlen) {
      return false;
    }
    if (nlen === hlen) {
      return needle === haystack;
    }
    outer: for (var i = 0, j = 0; i < nlen; i++) {
      var nch = needle.charCodeAt(i);
      while (j < hlen) {
        if (haystack.charCodeAt(j++) === nch) {
          continue outer;
        }
      }
      return false;
    }
    return true;
  },

  matchWhatInput: function(matches){
    if(typeof(matches) !== "object") {
      matches = [matches];
    }
    return matches.indexOf(whatInput.ask()) > -1;
  },

  // Create a JS list of icons
  icons: {}

};

Ornament.C = Ornament.Components;

$(document).on("ornament:refresh", function(){
  // Take the SVG icons and push them to Ornament.icons
  var $iconsContainer = $("[data-ornament-icons]");
  if($iconsContainer.length > 0) {
    $iconsContainer.children().each(function(){
      var $container = $(this);
      var iconName = Object.keys($container.data())[0].split("ornamentIcon")[1].toLowerCase();
      var iconMarkup = $container.html();
      Ornament.icons[iconName] = iconMarkup;
    });
    $iconsContainer.remove();
  }
});
