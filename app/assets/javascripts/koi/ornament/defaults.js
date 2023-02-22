Ornament = window.Ornament = {

  Components: {},

  jQueryUISupport: false,

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
