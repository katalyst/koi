//= require ./lib/redactor

$.fn.outerHTML || ($.fn.outerHTML = function ()
{
  return $ ('<div>').append (this.clone ()).html ()
})

$ (function () // [koi=wysiwyg]
{
  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var opt =
    {
      fileUpload: '#show-me-the-attachment-button'
    , convertDivs: true
    , buttons:
      [ 'html'
      , '|'
      , 'formatting'
      , '|'
      , 'bold'
      , 'italic'
      , 'underline'
//    , 'deleted'
      , '|'
      , 'unorderedlist'
      , 'orderedlist'
      , '|'
      , 'outdent'
      , 'indent'
      , '|'
      , 'video'
      , 'image'
      , 'file'
      , 'link'
      , 'table'
//    , '|'
//    , 'fontcolor'
//    , 'backcolor'
      , '|'
      , 'alignleft'
      , 'aligncenter'
      , 'alignright'
      , 'justify'
      , '|'
      , 'horizontalrule'
      ]
    }

    var app = $ (this).redactor (opt).data ().redactor
    var box = app.$box
    var bar = app.$toolbar
    var win = $ (window)

    $ (this.form).submit (function ()
    {
      app.$editor.find ('img').each (function ()
      {
        var img = $ (this)
        var src = img.attr ('src').split ('?')
        var path = src [0]
        var params = src [1]
        var deparams = params ? $.deparam (params) : {}
        for (var k in { width:true, height:true })
        {
          var kay = parseInt (img.css (k))
          deparams [k] = kay
        }
        img.attr ('src', path + '?' + $.param (deparams))
      })
      app.syncCode ()
    })

    app.showImage = function ()
    {
      this.saveSelection ()
      launchAssetManager ('/admin/images/new', function (url)
      {
        this._imageSet ("<img src='" + url + "' style='float:right;'></img>", true)
      })
    }

    app.showFile = function ()
    {
      this.saveSelection();

      if ($ (this.getParentNode ()).is ('a')) this.showLink ()

      else launchAssetManager ('/admin/documents/new', function (url)
      {
        var fileName = url.match (/[^\/]+$/).toString () || '...'
        if ($.browser.msie) this.restoreSelection()
        this.execCommand ('inserthtml', "<a href='" + url + "' target='_blank'>" + fileName + "</a>")
        if (! $.browser.msie) this.showLink ()
      })
    }

    function launchAssetManager (path, ok)
    {
      var iframe    = $.factory.iframe (path)
      var imodal    = $ ('<div class="asset-manager modal fade in">')
                      .html (iframe)
                      .appendTo ('body')
                      .modal ({ backdrop : true })
                      .modal ('show')
      var ibackdrop = imodal.next ('.modal-backdrop')

      iframe.load (function ()
      {
        var iwindow = iframe.contentWindow ()
        var iclose  = iwindow.close
        iwindow.close = function (asset)
        {
          if (asset) ok.call (app, asset)
          imodal.modal ('hide').on ('hidden', function ()
          {
            iclose ()
            imodal.remove ()
            ibackdrop.remove ()
          })
        }
      })
    }

    box.css ({ position: 'relative' })
    app.$editor.css ({ minHeight: 250 })

    var fixed = { position: 'fixed', top: 44, left: box.offset ().left + 1, zIndex: 1, width: box.width () }
    var absolute = { position: 'absolute', top: 0, left: 0, zIndex: 1, width: box.width () }

    bar.before ($ ('<div>', { height: bar.height () })).css (absolute)

    $ (window).on ('resize scroll', function ()
    {
      var scrollTop = win.scrollTop ()
      var boxTop = box.offset ().top
      var boxBot = boxTop + box.height ()
      bar.css (boxTop < scrollTop + 44 && scrollTop + 44 + bar.height () < boxBot ? fixed : absolute)
    })
  })
})
