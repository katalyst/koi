//= require      ./jquery/browser
// require_tree ./jquery
//= require koi/etc/ZeroClipboard.js

ZeroClipboard.setMoviePath ('/assets/ZeroClipboard.swf')

$ (document).on ('click', 'a[target=_clipboard]', function ()
{
  // return false
})

// hide settings modals
$ (document).on ('click', '#close-settings-modal', function ()
{
   $('#modal-for-extra').modal('hide');
})
