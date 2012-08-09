! function ($)
{
  $.fn.pop = Array.prototype.pop;

  $.fn.shift = Array.prototype.shift;

  $.fn.shiftString = function (defaults)
  {
    return typeof this [0] === 'string' ? this.shift () : defaults;
  }

  $.fn.popOptions = function (defaults)
  {
    return $.extend (defaults || {}, $.isPlainObject (this.last ()) ? this.pop () : {});
  }

  $.fn.withPop = function (predicate, f)
  {
    if (arguments.length === 1) [].unshift.call (arguments, function () { return true });
    var n, t;
    if ((n = this.length) && (t = this [n - 1]) && predicate (t)) return t;
  }

  $.fn.appear = function ()
  {
    return this.css ({ visibility: 'visible' });
  }

  $.fn.disappear = function ()
  {
    return this.css ({ visibility: 'hidden' });
  }

  $.factory = {

    iframe: function ()
    {
      var $arguments = $ (arguments)
      ,   opt = $arguments.popOptions ()
      ,   src = $arguments.shiftString (opt.src)
      ;
      return $ ('<iframe>', $.extend (opt, { src: src, frameborder: 0 })).disappear ().load (function ()
      {
        var $iframe = $ (this).appear ();

        var contentDoc = $iframe.$contentDocument ()
        ,   contentWidth = contentDoc.width ()
        ,   contentHeight = contentDoc.height ()
        ;
        $iframe.width (contentWidth).height (contentHeight);
      })
    }
  }

} (jQuery);
