jQuery (function ($)
{
  // Configuration ////////////////////////////////////////////////////////////

  $ ('.wysiwyg.source').liveQuery (function ()
  {
    CKEDITOR.replace (this, { filebrowserBrowseUrl          : '/admin/documents'
                            , filebrowserUploadUrl          : '/admin/documents'
                            , filebrowserImageBrowseUrl     : '/admin/images'
                            , filebrowserImageUploadUrl     : '/admin/images'
                            , filebrowserImageBrowseLinkUrl : '/admin/documents'
                            , filebrowserImageUploadLinkUrl : '/admin/documents'
                            , filebrowserWindowWidth        : 950
                            , filebrowserWindowHeight       : 780
                            })
  })

  //////////////////////////////////////////////////////////// Configuration //

  // Dynamic Toolbar //////////////////////////////////////////////////////////

  CKEDITOR.on ('instanceReady', function (ck)
  {
    var  dockHeight            = 44 // height of Koi menu bar, which is fixed
    var $window                = $ (window)
    var  container             = ck.editor.container.$
    var $container             = $ (container)
    var $containerWindow       = $container.find ('iframe').$contentWindow ()
    var $toolbar               = $container.find ('.cke_top')
    var $bar                   = $ ('<div>').css ({ width:$container.innerWidth (), height:$toolbar.outerHeight () })
    var  toolbarAbsolute       = { position:'absolute', top:0, left:0, width:$toolbar.css ('width') }
    var  toolbarFixed          = { position:'fixed', top:dockHeight, left:$toolbar.offset ().left }

    $container.css ({ position:'relative' })
    $toolbar.css (toolbarAbsolute)

    $bar.insertBefore ($toolbar)

    $window.on ('scroll', balance)
    $containerWindow.ready (balance)

    function balance ()
    {
      var containerOffset = $container.offset ()
      var containerTop    = containerOffset.top
      var containerBottom = containerOffset.top + $container.outerHeight ()
      var scrollTop       = $window.scrollTop ()

      var balanceTop      = scrollTop + dockHeight     - containerTop
      var balanceBottom   = scrollTop + dockHeight * 2 - containerBottom

      var balanceInside = balanceTop > 0 && balanceBottom < 0

      $toolbar.css (balanceInside ? toolbarFixed : toolbarAbsolute)
    }
  })

  ////////////////////////////////////////////////////////// Dynamic Toolbar //

})