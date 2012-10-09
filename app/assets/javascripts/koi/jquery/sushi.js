! function ($)
{
  var array = Array.prototype

  $.fn.sushi = function (name)
  {
    return new Sushi (this, name)
  }

  function Sushi ($element, name)
  {
    this.$element = $element
    this.name = name
  }

  var sushi = Sushi.prototype

  sushi.__send__ = function ()
  {
    return this.$element [this.name].apply (this.$element, arguments)
  }

  sushi.get = function (arg)
  {
    switch (arguments.length)
    {
      case 0: return $.extend ({}, all)

      case 1:
        if (typeof arg == 'string') return this.__send__ (arg)

      default: 
        var was = {}
        for (var i = 0; i < arguments.length; i ++) switch (typeof (arg = arguments [i]))
        {
          case 'string':
            was [arg] = this.__send__ (arg)

          case 'object':
            for (var key in arg) if (arg.hasOwnProperty (key)) was [key] = this.__send__ (key)
        }
        return was
    }
  }

  sushi.set1 = function (key, val)
  {
    var was = this.__send__ (key)
    this.__send__ (key, val)
    return was
  }

  sushi.set = function (arg)
  {
    var was = {}
    for (var i = 0; i < arguments.length; i ++) switch (typeof (arg = arguments [i]))
    {
      case 'string':
        was [arg] = sushi.set1.call (this, arg, arguments [i ++])

      case 'object':
        for (var key in arg) if (arg.hasOwnProperty (key))
          was [arg] = sushi.set1.call (this, key, arg [key])
    }
    return was
  }

  sushi.del1 = function (key)
  {
    var was = this.__send__ (key)
    this.__send__ (key, typeof was == 'string' ? '' : null)
    return was
  }

  sushi.del = function (arg)
  {
    var was = {}
    for (var i = 0; i < arguments.length; i ++) switch (typeof (arg = arguments [i]))
    {
      case 'string':
        was [arg] = sushi.del1.call (this, arg)

      case 'object':
        for (var key in arg) if (arg.hasOwnProperty (key))
          was [key] = sushi.del1.call (this, key)
    }
    return was    
  }

  var $css = $.fn.css, $attr = $.fn.attr

  $.fn.css = function ()
  {
    if (arguments.length > 0) return $css.apply (this, arguments)
    if (! this.length) return void 0
    var style = this.attr ('style')
    var pairs = style.split (';')
    var result = {}
    for (var i = 0; i < pairs.length; i ++)
    {
      var pair = pairs [i].match (/^\s*([^:]+)\s*:\s*(.*?)\s*$/)
      var key = pair [1]
      var val = pair [2]
      result [key] = val
    }
    return result
  }

  $.fn.attr = function ()
  {
    if (arguments.length > 0) return $attr.apply (this, arguments)
    if (! this.length) return void 0
    var it = this [0]
    var map = {}
    var attributes = it.attributes
    for (var i = 0; i < attributes.length; i ++)
    {
      var key = attributes [i].name
      var val = $attr.call (this, key)
      if (typeof val == 'string' && ! val.length) val = null
      if (val != null) map [key] = val
    }
    return map
  }
} (jQuery)
