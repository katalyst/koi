$(document).on("ornament:refresh", function(){
  
  var $lockButton = $("[data-sitemap-lock]");

  var toggleKoiSitemapDragDropState = function(){
    if(localStorage.koiSitemapDragDropDisabled) {
      koiSetSitemapDragDropState("enabled");
    } else {
      koiSetSitemapDragDropState("disabled");
    }
  }

  var koiSetSitemapDragDropState = function(state){
    if(state === "enabled") {
      localStorage.removeItem("koiSitemapDragDropDisabled");
      $lockButton.removeClass("button__depressed");
      $lockButton.text("Lock Dragging");
      $(document).trigger("ornament:koi:sitemap:unlocked");
    } else if (state === "disabled") {
      localStorage.setItem("koiSitemapDragDropDisabled", "true");
      $lockButton.addClass("button__depressed");
      $lockButton.text("Unlock Dragging");
      $(document).trigger("ornament:koi:sitemap:locked");
    }
  }

  // Some nice public functions
  Ornament.koiDisableSitemapDragDrop = function(){
    koiSetSitemapDragDropState("disabled");
  }
  Ornament.koiEnableSitemapDragDrop = function(){
    koiSetSitemapDragDropState("enabled");
  }

  if(localStorage) {
    // Set initial state
    if(localStorage.koiSitemapDragDropDisabled) {
      koiSetSitemapDragDropState("disabled");
    } else {
      koiSetSitemapDragDropState("enabled");
    }
    // Button press action
    $lockButton.on("click", function(e) {
      e.preventDefault();
      toggleKoiSitemapDragDropState();
    });
  }

  function $toNestedSet ()
  {
    var nodes = [];
    var n = 1;

    ! function ()
    {
      var $this = $ (this);
      var node = { id: $this.data ('id'), parent_id: $this.componentOf ().data ('id') };

      node.lft = n ++;
      $ (this).components ('.nav-item.application').each (arguments.callee);
      node.rgt = n ++;

      nodes.push (node);
    }.call (this);

    return nodes;
  }

  $ (".sitemap.application").application (function ($sitemap)
  {
    var path      = $sitemap.data ('uri-save');
    var $rootList = $sitemap.component ('ol');
    var $rootItem = $sitemap.component ('.nav-item');

    function save (cb) {
      $.post (path, { set: render () }, cb);
    }

    function render () {
      return JSON.stringify ($rootItem.call ($toNestedSet));
    }

    function bindSortable () {
      $rootList.not(".enabled").nestedSortable ({
        forcePlaceholderSize: true
      , handle: '.information'
      , helper: 'clone'
      , items: '.sortable'
      , opacity: .6
      , placeholder: 'placeholder'
      , revert: 250
      , tabSize: 32
      , tolerance: 'pointer'
      , toleranceElement: '> div'
      , maxLevels: 0
      , isTree: true
      , startCollapsed: false
      })
      .addClass("enabled")
      .on ("sortupdate", save);

      $('.disclose').off('click').on('click', function() {
        $(this).closest('li').toggleClass('mjs-nestedSortable-collapsed').toggleClass('mjs-nestedSortable-expanded');
        $(this).children("span").toggleClass('ui-icon-plusthick').toggleClass('ui-icon-minusthick');
      });
    }

    $(document).on("ornament:koi:sitemap:unlocked", function(){
      bindSortable();
    });

    $(document).on("ornament:koi:sitemap:locked", function(){
      $rootList.removeClass("enabled").nestedSortable("destroy");
    });

    bindSortable();

  });

  // $ (".nav-item.application").application (true, function ($item)
  // {
  //   var $zone = $item.component (".zone");
  //   var $body = $item.component (".body");
  //   var $link = $item.component (".pop-up");
  //   var $menu = $item.component (".controls");

  //   $link.click (function () { $.getScript (this.href); return false; });

  //   $zone.koiHover (25,
  //     function () {
  //       $menu.css ({ visibility: "visible" }).fadeIn (75);
  //       $body.animate ({ backgroundColor:"#e8e8e8" }, 75);
  //     },
  //     function () {
  //       $menu.delay(75).fadeOut (50);
  //       $body.delay(75).animate ({ backgroundColor:"rgba(0, 0, 0, 0)" }, 50);
  //     });
  // });
});
