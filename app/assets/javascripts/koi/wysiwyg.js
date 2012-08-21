//= require ./lib/redactor

$ (function () // [koi=wysiwyg]
{
  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var app = $ (this).redactor
      ({ fileUpload: '#show-me-the-attachment-button' }).data ().redactor

    app.showImage = function ()
    {
      var goo = this
      this.saveSelection ()
      launchAssetManager ('/admin/images/new', function (url)
      {
        console.log (url, "<img src='" + url + "' style='float:right;'></img>", 'gak')

        this._imageSet ("<img src='" + url + "' style='float:right;'></img>", true)
        goo.restoreSelection ()
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
