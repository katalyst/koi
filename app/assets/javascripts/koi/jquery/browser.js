if (! (typeof jQuery == 'undefined' || jQuery.browser)) ! function ($)
{
  $.uaMatch = function( ua ) {
    ua = ua.toLowerCase();

    var match = /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
      /(opera)(?:.*version)?[ \/]([\w.]+)/.exec( ua ) ||
      /(msie) ([\w.]+)/.exec( ua ) ||
      !/compatible/.test( ua ) && /(mozilla)(?:.*? rv:([\w.]+))?/.exec( ua ) ||
      [];

    return { browser: match[1] || "", version: match[2] || "0" };
  }

  $.browser = {}

  var userAgent = navigator.userAgent;
  var browserMatch = $.uaMatch( userAgent );
  
  if ( browserMatch.browser ) {
    $.browser[ browserMatch.browser ] = true;
    $.browser.version = browserMatch.version;
  }

  if ( $.browser.webkit ) {
    $.browser.safari = true;
  }

} (jQuery)
