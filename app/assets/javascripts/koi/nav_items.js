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

    function buildtoggles () {
      $.each($rootList.find(".nav-item"), function(){
        var $this = $(this);
        if(!$this.is("[data-toggleable]")) {
          return false;
        }
        if($this.find(".nav-item").length > 0) {
          if($this.find(".sitemap--toggler").length < 1) {
            var thisId = $(this).attr("data-id");
            var $childMenu = $this.children("ol");
            var activeClass = $childMenu.is(":visible") ? "active" : "";
            var $sitemapToggler = $("<div />").attr({
              "class": "sitemap--toggler " + activeClass,
              "data-toggle-anchor": "toggle_" + thisId,
              "data-toggle-group": "group_" + thisId
            });
            $childMenu.before($sitemapToggler);
            $sitemapToggler.on("click", function(e){
              e.preventDefault();
              Ornament.toggle($sitemapToggler, $childMenu);
            });
          }
        } else {
          $this.children(".sitemap--toggler").remove();
        }
      });
    }

    function save (cb) {
      buildtoggles ();
      $.post (path, { set: render () }, cb);
    }

    function render () {
      return JSON.stringify ($rootItem.call ($toNestedSet));
    }

    function bindSortable () {
      $rootList.not(".enabled").nestedSortable ({
        forcePlaceholderSize: true
      , handle: 'div'
      , helper: 'clone'
      , items: '.sortable'
      , opacity: .6
      , placeholder: 'placeholder'
      , revert: 250
      , tabSize: 25
      , tolerance: 'pointer'
      , toleranceElement: '> div'
      })
      .addClass("enabled")
      .on ("sortupdate", save);
    }

    $(document).on("ornament:koi:sitemap:unlocked", function(){
      bindSortable();
    });

    $(document).on("ornament:koi:sitemap:locked", function(){
      $rootList.removeClass("enabled").nestedSortable("destroy");
    });

    bindSortable();

  });

  $ (".nav-item.application").application (true, function ($item)
  {
    var $zone = $item.component (".zone");
    var $body = $item.component (".body");
    var $link = $item.component (".pop-up");
    var $menu = $item.component (".controls");

    $link.click (function () { $.getScript (this.href); return false; });

    $zone.koiHover (25,
      function () {
        $menu.css ({ visibility: "visible" }).fadeIn (75);
        $body.animate ({ backgroundColor:"#e8e8e8" }, 75);
      },
      function () {
        $menu.delay(75).fadeOut (50);
        $body.delay(75).animate ({ backgroundColor:"rgba(0, 0, 0, 0)" }, 50);
      });
  });
});
