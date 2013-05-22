//= require ./common
//= require ./ckeditor
//= require bootstrap

! function ($)
{
  // helpers //////////////////////////////////////////////////////////////////

  var $win = $window   = $.window   = $ (window)
  var $doc = $document = $.document = $ (document)

  function on ()
  {
    return $.fn.on.apply ($doc, arguments)
  }

  ////////////////////////////////////////////////////////////////// helpers //

  // default options //////////////////////////////////////////////////////////

  $.liveQuery.registerPlugin ('html')

  $.fn.modal.defaults = { backdrop: 'static', keyboard: true, show: true }

  $.application.debug = true;

  ////////////////////////////////////////////////////////// default options //

  // default widgetry /////////////////////////////////////////////////////////

  $ ('.date.input').application
    (true, function ($this) { $this.koiDatePicker () })

  $ ('.sortable.fields').application
    (true, function ($this) { $this.koiSortable () })

  $ ('.nested-fields').application
    (true, function ($this) { $this.koiNestedFields () })

  $ ('.superfish').application
    (true, function ($this) { $this.superfish ({ delay:100 }) })

  ///////////////////////////////////////////////////////// default widgetry //

  // bootstrap modal //////////////////////////////////////////////////////////

  var fnModal = $.fn.modal

  $.fn.modal = function ()
  {
    var it = $ (this)

    if (it.data ('modal'))
      return fnModal.apply (this, arguments)
    
    fnModal.apply (this, arguments)

    if (it.hasClass ('fade'))
      it.on ('show', function () { it.css ('top', $window.scrollTop () + 100) })
    
    return this
  }

  on ('click', 'a[target=_overlay]', function (event)
  {
    event.preventDefault ()
    $.modal (this.href)
  })

  $.modal = function (path, ok)
  {
    ok || (ok = function () {})
    var it = this
    var iframe    = $.factory.iframe (path)
    var imodal    = $ ('<div>')
                    .addClass ('asset-manager modal fade in')
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
        if (asset) ok.call (it, asset)
        imodal.modal ('hide').on ('hidden', function ()
        {
          iclose ()
          imodal.remove ()
          ibackdrop.remove ()
        })
      }
    })
  }

  ////////////////////////////////////////////////////////// bootstrap modal //

  // targetable tabs //////////////////////////////////////////////////////////

  $ (function ()
  {
    var hash = document.location.hash
    if (/^#tab-/.test (hash)) $ ('[href=' + hash + ']').click ()
  })

  ////////////////////////////////////////////////////////// targetable tabs //

  // dynamically removable fieldsets //////////////////////////////////////////

  on ('click', '[rel~=remove][rel~=fields]', function (event)
  {
    event.preventDefault ()

    $ (this).closest ('[role~=fields][role~=wrapper]').hide ()
            .find ('[id$=_destroy]').val (1)
  })

  ////////////////////////////////////////// dynamically removable fieldsets //

} (jQuery)
