if (! $.fn.outerHTML) $.fn.outerHTML = function ()
{
  return $ ('<div>').append (this.clone ()).html ()
}

! function ()
{
  var opt = {
    
    fileUpload: '#show-me-the-attachment-button'

  //  , convertDivs: true

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

  $ (function () { $ ('[koi-wysiwyg]').livequery (run) })

  function run ()
  {
    var textArea, form, box, iFrame, iQuery, iWindow, iDocument, iHead, iScript, iStyle, iBody, iTextArea, app

    textArea = $ (this).hide ()
    form = textArea.closest ('form').submit (submit_form)
    box = $ ('<div class="foo">').insertAfter (textArea).css ({ relative: true })
    iFrame = $ ('<iframe>', { src         : '/wysiwyg.html'
                            , width       : '100%'
                            , height      : '100%'
                            , frameborder : '0'
    }).appendTo (box).load (load_iFrame)

    function submit_form ()
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
      if (iTextArea.is (':hidden')) app.syncCode ()
      else app.toggle ()
      textArea.val (iTextArea.val ().replace (/&nbsp;/, ''))
    }

    function resize_iBody ()
    {
      iFrame.height (iBody.outerHeight ())
      iTextArea.height (app.$editor.innerHeight ())
    }

    function load_iFrame ()
    {
      iWindow   = iFrame.contentWindow ()
      iDocument = iFrame.contentDocument ()
      iQuery    = iWindow.$
      iHead     = iQuery (iDocument.getElementsByTagName ('head'))
      iBody     = iQuery (iFrame.contentDocument ().body)
      iTextArea = iQuery ('<textarea>').appendTo (iBody).val (textArea.val ())
      // iScript   = iQuery ('<script>', { src: '/assets/koi/lib/redactor.js' }).appendTo (iHead)
      // iStyle    = iQuery ('<link>', { src: '/assets/koi/redactor.css' }).appendTo (iHead)

      iBody.on ('click keydown', resize_iBody)
      // iScript [0].onload = (load_iScript)

      load_iScript ()
    }

    function load_iScript ()
    {
      app = iTextArea.redactor (opt).data ().redactor

      setTimeout (resize_iBody)

      //var box = app.$box
      var bar = app.$toolbar

      bar.detach ().insertBefore (iFrame)

      var snoggle = app.toggle

      app.toggle = function ()
      {
        this.saveScroll = $ (window).scrollTop ()
        snoggle.apply (this, arguments)
        setTimeout (resize_iBody)
        $ (window).scrollTop (this.saveScroll)
      }

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
        this.saveSelection()

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
      app.$editor.css ({ minHeight: 200 })

      var fixed = { position: 'fixed', top: 44, left: iFrame.offset ().left + 1, zIndex: 1, width: iFrame.width () - 2 }
      var absolute = { position: 'absolute', top: 0, left: 0, zIndex: 1, width: iFrame.width () - 2 }

      bar.before ($ ('<div>', { height: bar.height () })).css (absolute)

      $ (window).on ('resize scroll', function ()
      {
        var scrollTop = $ (window).scrollTop ()
        var boxTop = iFrame.offset ().top
        var boxBot = boxTop + iFrame.height ()
        bar.css (boxTop < scrollTop + 44 && scrollTop + 44 + bar.height () < boxBot ? fixed : absolute)
      })
    }
  }

} ()