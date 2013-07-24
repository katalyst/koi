//= require ./common
//= require ./ckeditor
//= require bootstrap

! function () {

  var $window = $ (window)

  $.liveQuery.registerPlugin ("html");

  $.fn.modal.defaults = {
        backdrop: 'static'
      , keyboard: true
      , show: true
    }

  $ (document).on ('click', '.redactor_editor', function ()
  {
    var it = $ (this)
    var textarea = it.siblings ('textarea')
    var redactor = textarea.data ('redactor')

    try { redactor.getCurrentNode () }
    catch (ex)
    {
      var range = rangy.createRange();
      range.setStart (this, 0);
      range.collapse (true);
      rangy.getSelection ().setSingleRange (range);
    }
  })

  $.application.debug = true;

  // $('.tab-content').application
  //   (function ($this) { $this.children ().maximise ('height'); });

  $ ('.date.input').application
    (true, function ($this) { $this.koiDatePicker () });

  // $('.rich.text.input').application
  //   (true, function ($this) { $this.koiEditor () });

  $ ('.sortable.fields').application
    (true, function ($this) { $this.koiSortable () });

  $ ('.nested-fields').application
    (true, function ($this) { $this.koiNestedFields () });

  $ ('.superfish').application
    (true, function ($this) { $this.superfish ({ delay:100 }); });

  var fnModal = $.fn.modal

  $.fn.modal = function ()
  {
    var it = $ (this)

    if (it.data ('modal')) return fnModal.apply (this, arguments)

    fnModal.apply (this, arguments)

    if (it.hasClass ('fade')) it.on ('show', function () { it.css ('top', $window.scrollTop () + 100) })
    return this
  }

  $ (document).on ('click', 'a[target=_overlay]', function ()
  {
    var it = $ (this)
    $.modal (it.attr ('href'))
    return false
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

  $ (function ()
  {
    // FIXME: Needs attention
    if(document.location.hash == '#tab-settings') {
      $ ('[href=#tab-settings]').click ();
    } else if(document.location.hash == '#tab-extra') {
      $ ('[href=#tab-extra]').click ();
    }
  })

} (jQuery);
