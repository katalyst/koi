jQuery (function ($)
{
  // Configuration ////////////////////////////////////////////////////////////

  function wysiwyg ()
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
  }

  $.fn.wysiwyg = function ()
  {
    return this.each (wysiwyg)
  }

  $ ('.wysiwyg.source').liveQuery (wysiwyg)

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
    $containerWindow.ready (balance).load (balance)

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

  // Tidy Source //////////////////////////////////////////////////////////////

  function either ()
  {
    return [].join.call (arguments, '|')
  }

  function opening (pattern)
  {
    return '(<(' + pattern + ')\\b[^>]*>)'
  }

  function closing (pattern)
  {
    return '(</(' + pattern + ')\\b[^>]*>)'
  }

  function opening_or_closing (pattern)
  {
    return '(</?(' + pattern + ')\\b[^>]*>)'
  }

  function left_spaced (pattern)
  {
    return '\\s+' + pattern
  }

  function right_spaced (pattern)
  {
    return pattern + '\\s+'
  }

  function maybe_spaced (pattern)
  {
    return '\\s*' + pattern + '\\s*'
  }

  function expression (pattern)
  {
    return new RegExp (pattern, 'gi')
  }

  function indent (number)
  {
    return INDENTS.substring (0, number * 2)
  }

  function style (name)
  {
    return '\\s*\\b(' + name + '):\\s*[^;]+;\\s*'
  }

  var INLINE  = 'a|abbr|b|bdi|bdo|cite|del|dfn|em|i|ins|kbd|mark|q|rp|rt|samp|small|span|strong|sub|sup|time|var|wbr'
  var BLOCK   = 'address|article|aside|audio|blockquote|body|button|caption|code|colgroup|datalist|dd|details|div|[dou]l|d[lt]|embed|fieldset|figcaption|figure|footer|form|h[1-6]|head|header|hgroup|html|label|legend|li|map|menu|meter|nav|noscript|object|optgroup|option|output|progress|script|p|pre|ruby|section|select|video|audio|style|summary|table|tbody|tfoot|thead|t[dhr]|textarea|title|video|audio|video'
  var VOID    = 'area|base|[bh]r|canvas|col|command|iframe|img|input|keygen|link|meta|param|source|track'
  var ANY     = '[\\w:]+'
  var TAGLESS = '[^<>]*'
  var INDENTS = '                                                                                               '

  var toDataFormat_super = CKEDITOR.htmlDataProcessor.prototype.toDataFormat
  var toDataFormat = function (html)
  {
    var data = toDataFormat_super.call (this, html)
    data = data.replace (expression (left_spaced  (opening (INLINE))), ' $1')
               .replace (expression (right_spaced (closing (INLINE))), '$1 ')
               .replace (expression (maybe_spaced (opening_or_closing (either (BLOCK, VOID)))),'\n$1\n')
               .replace (expression (right_spaced (opening (ANY)) + TAGLESS + left_spaced (closing (ANY))), function (match, $1, $2, $3, $4) { return $2 == $4 ? match.replace (/[\n\r]/g, '') : match })
               .replace (/\r/g, '\n').replace (/\n+/g, '\n').replace (/^\s+/g, '').replace (/\s+$/g, '')
               .replace (expression (style (either ('line-height', 'font-size', 'font-family', 'color'))), '')
               .replace (/\sstyle=['"]\s*['"]/ig, '')

    data = data.split ('\n')
    for (var n = 0, i = 0; i < data.length; i ++)
    {
      var isOpening = expression (opening (BLOCK)).test (data [i])
      var isClosing = expression (closing (BLOCK)).test (data [i])

           if (isOpening && ! isClosing) {       data [i] = indent (n) + data [i]; n ++ }
      else if (isClosing && ! isOpening) { n --; data [i] = indent (n) + data [i]       }
      else                               {       data [i] = indent (n) + data [i]       }
    }
    return data.join ('\n')
  }

  CKEDITOR.htmlDataProcessor.prototype.toDataFormat = toDataFormat

  ////////////////////////////////////////////////////////////// Tidy Source //

})
