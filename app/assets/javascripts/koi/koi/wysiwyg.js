! function ()
{
  var opt = { fileUpload: '#show-me-the-attachment-button', buttons: ['html'] }

  opt.buttons.add = function (split)
  {
    this.push ('|'); this.push.apply (this, split.split (' ')); return this
  }
  opt.buttons
  .add ('formatting')
  .add ('bold italic underline')
  .add ('unorderedlist orderedlist')
  .add ('outdent indent')
  .add ('video image file link table')
  .add ('alignleft aligncenter alignright justify')
  .add ('horizontalrule')

  $ (function () { $ ('[koi-wysiwyg]').liveQuery (run) })

  function run ()
  {
    var app, $box, $editor, $toolBar
    var $win = $ (window), $textArea = $ (this), $form = $textArea.closest ('form')
    var iFrame, iQuery, iWindow, iDocument, iHead, iBody, iScript, iStyle, iTextArea

    $textArea.hide ().closest ('form').on ('submit', submit)

    iFrame = $ ('<iframe frameBorder="0">').insertAfter ($textArea).load (loadFrame)
    .attr ('src'          , '/wysiwyg.html')
    .attr ('width'        , '100%')
    .attr ('height'       , '100%')
    .attr ('marginheight' , '0')
    .attr ('marginheight' , '0')
    .css  ('borderWidth'  , '0')
    .css  ('borderStyle'  , 'none')

    function submit ()
    {
      $editor.find ('img').each (function ()
      {
        var $img     = $ (this)
        var src      = $img.attr ('src').split ('?')
        var path     = src [0]
        var params   = src [1]
        var deparams = params ? $.deparam (params) : {}
        if (params)
        {
          for (var dim in { width:true, height:true })
          {
            $img.css (dim, $img [dim] ())
            deparams [dim] = parseInt ($img.css (dim))
          }
          $img.attr ('src', path + '?' + $.param (deparams))
        }
        // else $img.attr ('style', '');
      })
      if (iTextArea.is (':hidden')) app.syncCode ()
      else app.toggle ()
      $textArea.val ($editor[0].innerHTML.replace (/(<\w[^>]*>)\s*<br\/?>/gi, function ($0, $1) { return $1 + ' ' })
                                         .replace (/(<\/[^>]*>)\s*&nbsp;/gi,  function ($0, $1) { return $1 + ' ' })
                                         .replace (/<p>\s*<\/p>/gi, '')
                                         .replace (new RegExp ('href="' + location.protocol + '//' + location.host, 'g'), 'href="')
                                         .replace (new RegExp ("href='" + location.protocol + '//' + location.host, 'g'), "href='")
                                         .replace (/cursor\s*:\s*default;?/gi, ''))
    }

    function resize_body ()
    {
      iFrame.height ($ (iBody).outerHeight () + $toolBar.outerHeight ())
    }

    var diffo

    function resize_document ()
    {
      if (diffo == null) diffo = $ (iDocument).outerHeight () - $ (iBody).outerHeight ()
      iTextArea.height (app.opts.visual ? $editor.height () : iTextArea [0].scrollHeight)
      iFrame.height ($ (iBody).outerHeight () + diffo)
    }

    function resizer ()
    {
      resize_body (); resizer = resize_document;
    }

    function resize ()
    {
      resizer (); setTimeout (function () { resizer () })
    }

    function loadFrame ()
    {
      iWindow   = iFrame.contentWindow ()
      iDocument = iFrame.contentDocument ()

      iHead     = iDocument.getElementsByTagName ('head') [0]
      iBody     = iDocument.getElementsByTagName ('body') [0]

      iTextArea = iDocument.createElement ('textarea')
      iTextArea.value = $textArea.val ()
      iBody.appendChild (iTextArea)

      iStyle       = iDocument.createElement ('link')
      iStyle.rel   = 'stylesheet'
      iStyle.type  = 'text/css'
      iStyle.media = 'screen'
      iStyle.href  = '/assets/koi/jquery/redactor.css'
      iHead.appendChild (iStyle)

      iScript      = iDocument.createElement ('script')
      iScript.type = 'text/javascript'
      iScript.src  = '/assets/koi.js'

      // Handle Script loading
      var done = false;

      // Attach handlers for all browsers
      iScript.onload = iScript.onreadystatechange = function ()
      {
        if (! done && (! this.readyState || this.readyState == 'loaded' || this.readyState == 'complete'))
        {
          done = true
          loadScript ()

          // Handle memory leak in IE:
          iScript.onload = iScript.onreadystatechange = null
          if (iHead && iScript.parentNode) iHead.removeChild (iScript)
        }
      }

      iHead.appendChild (iScript)

      $ (iBody).css ({ padding:0, margin:0 }).on ('click keydown', resize)

      //$ (iScript).load (loadScript)
    }

    function loadScript ()
    {
      iBody = iWindow.$ (iBody)
      iTextArea = iWindow.$ (iTextArea)
      // iScript [0].onload = (load_iScript)

      app = iTextArea.redactor (opt).data ().redactor
      app.modalex = $.modal

      $box = iFrame
      $editor = app.$editor.css ({ minHeight: 300, padding:0, margin:0 })
      $toolBar = app.$toolbar

      var sushiBar = $toolBar.sushi ('css')

      sushiBar.set ({ boxSizing: 'border-box', width:'100%' })

      sushiBar.stopScrolling = function ()
      {
        var boxWidth  = $editor.outerWidth ()
        this.set ({ position:'absolute', zIndex:1, left:0, top:0, width:'100%' })
      }

      sushiBar.startScrolling = function ()
      {
        var boxTop    = $box.offset ().top
        var scrollTop = $win.scrollTop ()
        this.set ({ top: scrollTop - boxTop + 43 })
      }

      sushiBar.isScrolling = function ()
      {
        var boxTop    = $box.offset ().top
        var boxHeight = $box.height ()
        var boxBottom = boxHeight + boxTop - 44 - 32
        var scrollTop = $win.scrollTop ()
        var top       = scrollTop + $toolBar.height ()
        return boxTop < top && top < boxBottom
      }
      sushiBar.stopScrolling ()
      sushiBar.startScrolling ()

      function reposition ()
      {
        sushiBar [sushiBar.isScrolling () ? 'startScrolling' : 'stopScrolling'] ()
        setTimeout (function () { sushiBar [sushiBar.isScrolling () ? 'startScrolling' : 'stopScrolling'] () })
      }

      function slappy ()
      {
        resize (); reposition ();
      }

      $ (window).ready (function ()
      {
        slappy (); setTimeout (slappy)
        $editor.find ('img').load (slappy)
      })

      $ (window).on ('resize scroll', reposition)

      var __toggle = app.toggle

      app.toggle = function ()
      {
        var scrollTop = $win.scrollTop ()
        __toggle.apply (this, arguments)
        setTimeout (resize)
        $win.scrollTop (scrollTop)
      }

      app.showImage = function ()
      {
        this.saveSelection ()
        $.modal.call (this, '/admin/images/new', function (opt)
        {
          var url = opt.url + '?'
          var style = "float:right;"
          if (typeof opt.width  == 'string')
          {
            style += "width:"  + opt.width  + ";"
            if (/^[0-9]+px$/.test (opt.width)) url += 'width=' + opt.width  + '&'
          }
          if (typeof opt.height == 'string')
          {
            style += "height:" + opt.height + ";"
            if (/^[0-9]+px$/.test (opt.height)) url += 'height=' + opt.height + '&'
          }
          this._imageSet ("<img src='" + url + "' style='" + style + "'></img>", true)
          slappy ()
        })
      }

      app.showFile = function ()
      {
        this.saveSelection()

        if ($ (this.getParentNode ()).is ('a')) this.showLink ()

        else $.modal.call (this, '/admin/documents/new', function (opt)
        {
          var url = opt.url
          var fileName = url.match (/[^\/]+$/).toString () || '...'
          var text = app.getSelection ()
          if (! text || ! /\S/.test (text)) text = fileName
          if ($.browser.msie) this.restoreSelection()
          this.execCommand ('inserthtml', "<a href='" + url + "' target='_blank'>" + text + "</a>")
          if (! $.browser.msie) this.showLink ()
        })

        slappy ()
      }

      $toolBar.before ($ ('<div>&nbsp;</div>').css ({ height:'32px' }))
    }
  }

} ()

