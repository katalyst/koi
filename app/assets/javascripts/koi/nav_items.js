$ (function () {

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
        if($this.find(".nav-item").length > 0) {
          if($this.find(".sitemap--toggler").length < 1) {
            var thisId = $(this).attr("data-id");
            var $sitemapToggler = $("<div />").attr({
              "class": "sitemap--toggler active",
              "data-toggle-anchor": "toggle_" + thisId,
              "data-toggle-group": "group_" + thisId
            });
            var $childMenu = $this.children("ol");
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

    $rootList.nestedSortable ({
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
    .on ("sortupdate", save);
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
