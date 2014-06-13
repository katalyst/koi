//= require_tree ./shim
//= require jquery
//= require jquery.ui.all
//= require jquery_ujs
//= require select2
//= require      ./jquery/browser
//= require_tree ./jquery
//= require_tree ./koi
//= require ./etc/ZeroClipboard
//= require rickshaw_with_d3

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
