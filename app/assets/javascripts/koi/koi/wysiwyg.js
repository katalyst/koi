! function ()
{
  var opt = { fileUpload: '#show-me-the-attachment-button', buttons: ['html'] }

  opt.buttons.add = function (split)
  {
    this.push ('|')
    this.push.apply (this, split.split (' '))
    return this
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
    var app, $editor, $toolBar
    var $win = $ (window), $textArea = $ (this), $form = $textArea.closest ('form')
    var iFrame, iQuery, iWindow, iDocument, iHead, iBody, iScript, iStyle, iTextArea

    $textArea.hide ().closest ('form').on ('submit', submit)

    iFrame = $ ('<iframe>').insertAfter ($textArea).load (loadFrame)
    .attr ('src', '/wysiwyg.html?' + Math.random ())
    .attr ('width', '100%')
    .attr ('height', '100%')
    .attr ('frameborder', '0')

    function submit ()
    {
      $editor.find ('img').each (function ()
      {
        var $img = $ (this)
        var src = $img.attr ('src').split ('?')
        var path = src [0]
        var params = src [1]
        var deparams = params ? $.deparam (params) : {}
        if (params)
        {
          for (var dim in { width:true, height:true }) deparams [dim] = parseInt ($img.css (dim))
          $img.attr ('src', path + '?' + $.param (deparams))
        }
        else $img.attr ('style', '');
      })
      if (iTextArea.is (':hidden')) app.syncCode ()
      else app.toggle ()
      $textArea.val (iTextArea.val ().replace (/(\s*&nbsp;\s*)+/, ' '))
    }

    function resize ()
    {
      var height = iBody.outerHeight () + $toolBar.outerHeight () + 37
      iTextArea.height (height)
      iFrame.height (height)
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
      };

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

      $box = iFrame
      $editor = app.$editor.css ({ minHeight: 200, padding:0, margin:0 })
      $toolBar = app.$toolbar

      var sushiBar = $toolBar.sushi ('css')

      sushiBar.stopScrolling = function ()
      {
        var boxWidth  = $editor.outerWidth ()
        this.set ({ position:'absolute', zIndex:1, left:0, top:0, width:boxWidth - 2 })
      }

      sushiBar.startScrolling = function ()
      {
        var boxTop    = $box.offset ().top
        var scrollTop = $win.scrollTop ()
        this.set ({ top: scrollTop - boxTop + 44 })
      }

      sushiBar.isScrolling = function ()
      {
        var boxTop    = $box.offset ().top
        var boxHeight = $box.height ()
        var boxBottom = boxHeight + boxTop
        var scrollTop = $win.scrollTop ()
        var top       = scrollTop + $toolBar.height ()
        return boxTop < top && top < boxBottom
      }

      function reposition ()
      {
        sushiBar [sushiBar.isScrolling () ? 'startScrolling' : 'stopScrolling'] ()
      }

      setTimeout (resize)
      setTimeout (reposition)

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
        $.modal.call (this, '/admin/images/new', function (url)
        {
          this._imageSet ("<img src='" + url + "' style='float:right;'></img>", true)
        })
      }

      app.showFile = function ()
      {
        this.saveSelection()

        if ($ (this.getParentNode ()).is ('a')) this.showLink ()

        else $.modal.call (this, '/admin/documents/new', function (url)
        {
          var fileName = url.match (/[^\/]+$/).toString () || '...'
          if ($.browser.msie) this.restoreSelection()
          this.execCommand ('inserthtml', "<a href='" + url + "' target='_blank'>" + fileName + "</a>")
          if (! $.browser.msie) this.showLink ()
        })
      }

      $toolBar.before ($ ('<div>', { height: '33px' }))
    }
  }

} ()

