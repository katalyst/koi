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

    function save (cb) {
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
