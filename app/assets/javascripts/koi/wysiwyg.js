//= require ./lib/redactor

$ (function () // [koi=wysiwyg]
{
  $.fn.outerHTML || ($.fn.outerHTML = function ()
  {
    return $ ('<div>').append (this.clone ()).html ()
  })

  $ ('[koi=wysiwyg]').livequery (function ()
  {
    var app = $ (this).redactor
      ({ fileUpload: '#show-me-the-attachment-button' }).data ().redactor

    function nodeName (el)
    {
      return el [$.browser.msie ? 'nodeName' : 'tagName']
    }

    app.getCurrentNodeName = function ()
    {
      return nodeName (this.getCurrentNode ())
    }

    app.getParentNodeName = function ()
    {
      return nodeName (this.getParentNode ())
    }

    app.showImage = function ()
    {
      launchAssetManager ('/admin/images/new', function (asset)
      {
        this._imageSet ($ ('<img>', asset).outerHTML (), true)
      })
    }

    app.showFile = function ()
    {
      if (this.getParentNodeName () == 'A') this.showLink ()

      else launchAssetManager ('/admin/documents/new', function (asset)
      {
        var fileName = asset.href.match (/[^\/]+$/).toString ()
        this.execCommand ('inserthtml', $ ('<a>', asset).text (fileName).outerHTML ())
        this.showLink ()
      })
    }

    function launchAssetManager (path, ok)
    {
      var iframe  = $.factory.iframe (path)
      var imodal  = $ ('<div class="asset-manager modal fade hide">')

      imodal.appendTo ('body').modal ({ backdrop: true }).modal ('show').removeClass ('hide').addClass ('in').html (iframe)

      iframe.load (function ()
      {
        var iwindow = iframe.contentWindow ()
        var iclose  = iwindow.close
        iwindow.close = function (asset)
        {
          if (asset) ok.call (app, asset)

          $ ('.modal-backdrop').remove ()
          
          imodal.modal ('hide', function ()
          {
            imodal.remove ()
            iclose.call (iwindow)
          })
        }
      })
    }
  })
})
