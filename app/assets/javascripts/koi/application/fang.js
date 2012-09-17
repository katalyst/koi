// this needs a LOT more work before useable in all browsers:
// http://reference.sitepoint.com/javascript/Node/attributes

// probably need to use something like .outerHTML (which doesn't exist either)

var attr = $.fn.attr

$.fn.attr = function ()
{
  if (arguments.length > 0 || ! this.length) return attr.apply (this, arguments)
  var it = this [0]
  var map = {}
  var attributes = it.attributes
  for (var i = 0; i < attributes.length; i ++)
  {
    var key = attributes [i].name
    var val = this.attr (key)
    if (typeof val == 'string' && ! val.length) val = null
    if (val != null) map [key] = val
  }
  return map
}
