(function() {

  // IE8 doesn't support window.innerWidth/innerHeight
  // this is a function which will fill in innerWidth and innerHeight with the
  // correct values using functions IE can understand.
  // Why use window.innerWidth instead of $(window).width() or $(window).innerWidth()?
  // $(window).width() includes the scrollbar, whereas window.innerWidth is the
  // ACTUAL innerWidth of the viewport

  Ornament.windowWidth = function(){
    return window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
  }

  Ornament.windowHeight = function(){
    return window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
  }

}());