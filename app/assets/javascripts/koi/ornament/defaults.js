Ornament = window.Ornament || {};
Ornament.ready = false;
Ornament.version = "1.2.6";

// =========================================================================
// Internal settings
// =========================================================================

// Header Breakpoint
// Should match $breakpoint-header in settings.css
Ornament.headerBreakpoint = 990;

// Core settings
Ornament.externalLinkExtensions = [];
Ornament.internalLinkSelectors = [];

// Map colours
Ornament.mapColours = false;
// Ornament.mapColours = [{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0182c6"}]},{"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#7ac043"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#7ac043"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#7ac043"},{"lightness":-40}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#7ac043"},{"lightness":-20}]},{"featureType":"road.local","elementType":"geometry","stylers":[{"color":"#7ac043"},{"lightness":-17}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"},{"visibility":"on"},{"weight":0.9}]},{"elementType":"labels.text.fill","stylers":[{"visibility":"on"},{"color":"#ffffff"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"simplified"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"transit","elementType":"geometry","stylers":[{"color":"#7ac043"},{"lightness":-10}]},{},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#7ac043"},{"weight":0.7}]}];

// =========================================================================
// Components storage
// =========================================================================

// Components API
Ornament.Components = {};

// Short namespace for Components
// eg. Ornament.C.Toggles
Ornament.C = Ornament.Components;

// =========================================================================
// Service support
// =========================================================================

Ornament.features = {}
Ornament.features.serviceWorker = "serviceWorker" in navigator;
Ornament.features.geolocation = "geolocation" in navigator;
Ornament.features.turbolinks = typeof(Turbolinks) !== "undefined" && Turbolinks.supported;
Ornament.features.jQueryUISupport = true;

// =========================================================================
// Popup Defaults
// =========================================================================

Ornament.popupOptions = {
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
};

Ornament.popupOpened = function(resize){
  resize = resize || false;
  $(document).trigger("ornament:tabs");
  $(document).trigger("ornament:toggles");
  $(document).trigger("ornament:enhance-forms");
  $(document).trigger("ornament:map_refresh");
  if(resize) {
    Ornament.globalLightboxSizing();
  }
};

Ornament.showHideXYShadows = function($element) {
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
Ornament.sizeLightboxToViewport = function(mfp){
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
};

// Size all lightboxes to the screen
Ornament.globalLightboxSizing = function(){
  var currentLightboxElement = $.magnificPopup.instance;
  if (currentLightboxElement.currItem) {
    Ornament.sizeLightboxToViewport(currentLightboxElement);
  }
};

// =========================================================================
// Helper functions
// =========================================================================

// Animated scroll 
Ornament.bodyScroll = function(offset, timing){
  $("html,body").animate({
    scrollTop: offset
  }, timing);
};

// Asset Loader
// Loads in an array of assets then removes itself
// usage: Ornament.assetPreloader(["/assets/image1.jpg", "/assets/image2.png"]);
Ornament.assetPreloader = function(assets){
  assets = assets || [];
  $.each(assets, function(){
    var image = new Image();
    image.src = this;
  });
};

// Parameterize function
Ornament.parameterize = function(url) {
  return url.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');
};

// Fuzzysearch
// https://github.com/bevacqua/fuzzysearch/blob/master/index.js
Ornament.fuzzySearch = function(needle, haystack){
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
}

Ornament.matchWhatInput = function(matches){
  if(typeof(matches) !== "object") {
    matches = [matches];
  }
  return matches.indexOf(whatInput.ask()) > -1;
}

// A helper wrapper to push public functions to the Component API
// Ornament.componentise("myComponent", { 
//  privateFunc: function() { alert("test"); } 
//  public: { showAlert: this.privateFunc(); } 
//});
// Ornament.C.myComponent.showAlert(); 
Ornament.componentise = function(name, component){
  Ornament.C[name] = component.public;
}

// =========================================================================
// SVG Icons via JS
// =========================================================================

Ornament.icons = {};
Ornament.loadIcons = function() {
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
};

// =========================================================================
// Event Listeners
// Ornament.onScroll(function(){ console.log("hi") });
// =========================================================================

// OnLoad
// If ornament has already triggered, run it now
// If ornament isn't ready yet, wait until the refresh trigger
Ornament.onLoad = function(callback) {
  if(Ornament.ready) { callback; }
  $(document).on("ornament:refresh", callback);
}

Ornament.onScroll = function(func) {
  $(window).off("scroll", func).on("scroll", func);
}

Ornament.onResize = function(func) {
  $(window).off("resize", func).on("resize", func);
}

// =========================================================================
// Things to set after page is loaded
// =========================================================================
Ornament.onLoad(function(){
  Ornament.features.ie8 = $("body").hasClass("ie8");
  Ornament.loadIcons();
});

Ornament.C = Ornament.Components;

// Refreshing Ornament for Turbolink visits
if(Ornament.features.turbolinks) {
  $(document).on("turbolinks:load", function(){
    Ornament.refresh && Ornament.refresh();
  });
}

