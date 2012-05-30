! function ($)
{
  $.fn.htmlIframe = function ()
  {
    var sig = [].slice.call (arguments), src, opt;

    if (typeof sig [0] === 'string') src = sig.shift ();
    if (typeof sig [0] === 'object') opt = sig.shift ();
    
    if (opt        == null) opt = {};
    if (opt.src    == null) opt.src = src;
    if (opt.width  == null) opt.width = this.innerWidth ();
    if (opt.height == null) opt.height = this.innerHeight ();
    opt.frameBorder = 0;

    var $iframe = $ ('<iframe>').attr (opt);
    this.html ($iframe);

    return this;
  }
} (jQuery);
