//= require ./lib/redactor

$.fn.outerHTML || ($.fn.outerHTML = function ()
{
  return $ ('<div>').append (this.clone ()).html ()
})

$ (function () // [koi=wysiwyg]
{
  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var opt = { fileUpload: '#show-me-the-attachment-button' }

    var app = $ (this).redactor (opt).data ().redactor

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
  })
})
