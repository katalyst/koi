!(function ($) {
  var was = { on: $.fn.on, one: $.fn.one, off: $.fn.off, find: $.find };
  var $document = $(document);
  var array = Array.prototype,
    object = Object.prototype;

  ///////////////////////////////////////////////////////////////////////////////
  // Utility functions //////////////////////////////////////////////////////////

  var classOf = ($.classOf = function (obj) {
    return object.toString.call(obj);
  });

  var TypeOf = ($.TypeOf = function (obj) {
    return classOf(obj).match(/\[object (\w+)\]/)[1];
  });

  var typeOf = ($.typeOf = function (obj) {
    return TypeOf(obj).toLowerCase();
  });

  var objectOf = ($.objectOf = function (obj) {
    return Object(obj);
  });

  if (typeOf(Object.getPrototypeOf) == "function")
    var prototypeOf = ($.prototypeOf = function (obj) {
      return Object.getPrototypeOf(obj);
    });
  else if (typeof $.__proto__ == "object")
    var prototypeOf = ($.prototypeOf = function (obj) {
      return obj.__proto__;
    });
  else
    var prototypeOf = ($.prototypeOf = function (obj) {
      return obj.constructor.prototype;
    });

  var maybeOf = ($.maybeOf = function (obj) {
    if (isMaybe(obj)) return obj;
  });

  var isMaybe = ($.isMaybe = function (obj) {
    switch (typeOf(obj)) {
      case "string":
      case "array":
        return !!obj.length;

      case "object":
        for (var key in obj) if (obj.hasOwnProperty(key)) return true;

      default:
        return obj;
    }
  });

  ///////////////////////////////////////////////////////////////////////////////
  // Utility methods ////////////////////////////////////////////////////////////

  $.fn.pop = array.pop;
  $.fn.push = array.push;
  $.fn.shift = array.shift;
  $.fn.unshift = array.unshift;
  $.fn.reverse = array.reverse;

  // Return the HTML of the current selection
  //
  if (!$.fn.outerHTML)
    $.fn.outerHTML = function () {
      return $("<div>").append(this.clone()).html();
    };

  ///////////////////////////////////////////////////////////////////////////////
  // Event methods and functions ////////////////////////////////////////////////

  // Alternate syntax for `on`, `one`, `off`:
  //
  //   $.on (...) // shortcut for $ (document).on (...)
  //
  //   $ (...) (function () { ... }) // curried form
  //   $ (...) ({ click: function () { ... }})
  //
  for (var key in was)
    !function (key, fun) {
      var pleasure = ($.fn[key] = function () {
        var curried = arguments;
        var first = arguments[0],
          last = arguments[arguments.length - 1];

        return typeof first == "object" || typeof last == "function"
          ? fun.apply(this, arguments)
          : function (handler) {
              switch (typeof handler) {
                case "object":
                  array.unshift.call(arguments, curried);
                case "function":
                  array.push.call(arguments, curried);
              }
              return fun.apply(this, arguments);
            };
      });

      $[key] = function () {
        return pleasure.apply($document, arguments);
      };
    }.call(key, was[key]);

  // Alternate form of `setTimeout`:
  //
  //   $.delay (2000, function () { ... })
  //
  //   $.delay (2000) (function () { ... })
  //
  var delay = ($.delay = function (t, f) {
    if (typeof f != "function")
      return function (f) {
        delay(t, f);
      };
    setTimeout(f, t);
  });

  // Alternate to `setInterval`:
  //
  //   $.poll (2000, function () { ... }) // start in 2000 ms, and poll every 2000 ms
  //
  //   $.poll (0) (function () { ...; return 2000 }) // start now, and poll every 2000 ms
  //
  //   $.poll (2000) (function ()) // curried form
  //
  // Return anything except a `number` or `undefined` when done:
  //
  //   $.poll (2000) (function () { ...; if (finished) return false })
  //
  var poll = ($.poll = function (t, f, done) {
    if (typeof f != "function")
      return function (f, done) {
        return poll(t, f, done);
      };
    setTimeout(function () {
      var next = f();
      switch (typeof next) {
        case "undefined":
          next = t;
        case "number":
          poll(next, f);
        default:
          if (typeof done == "function") done(next);
      }
    }, t);
  });

  // Returns all of the handlers for the given `type` triggered by the first element
  //
  $.fn.handlersOn = function (type) {
    var events,
      handlers,
      $it = ($up = this.first()),
      bindings = [];

    if ((events = $it.data("events")))
      if ((handlers = events[type]))
        for (var i = 0; i < handlers.length; i++)
          if (!handlers[i].selector) bindings.push(handlers[i]);

    while (($up = $up.parent()).length) {
      if ((events = $up.data("events")))
        if ((handlers = events[type]))
          for (var i = 0; i < handlers.length; i++)
            if ($up.is(handlers[i].selector)) bindings.push(handlers[i]);
    }

    for (var i in $.cache) {
      if ((events = $.cache[i].events))
        if ((handlers = events[type]))
          for (var j in handlers)
            if ($it.is(handlers[j].selector)) bindings.push(handlers[j]);
    }

    return bindings;
  };

  ///////////////////////////////////////////////////////////////////////////////
  // Selector methods ///////////////////////////////////////////////////////////

  // Alternate form of `find`, allows thunked selectors
  //
  $.find = function (arg, ctx) {
    if (typeof arg == "function") arg = arg();
    return was.find.apply(this, arguments);
  };

  for (var key in was.find) $.find[key] = was.find[key];

  // Return `that` if `this` is empty
  //
  $.fn.or = function (that) {
    return this.length ? this : $.find(that);
  };

  ///////////////////////////////////////////////////////////////////////////////
  // Evaluation methods /////////////////////////////////////////////////////////

  // Apply the given function to this and the current selection
  //
  $.fn.call = function (f) {
    return f.apply(this, this.toArray());
  };

  // Alternative form of `each`, applies the given function in the context of the jQuery object,
  // rather than the element.
  //
  $.fn.each$ = function (f) {
    return this.each(function () {
      return f.apply($(this), arguments);
    });
  };

  // Alternative form of `map`, applies the given function in the context of the jQuery object,
  // rather than the element.
  //
  $.fn.map$ = function (f) {
    return this.map(function () {
      return f.apply($(this), arguments);
    });
  };

  // Returns the minimum of the given function applied to each element in the selection.
  // Resolves `f` as a jQuery method if it's a string.
  //
  $.fn.min = function (f) {
    if (typeof f == "string") return this.min$(f);
    return Math.min(this.map(f).toArray());
  };

  // Alternative form of `min`, applies the given function in the context of the jQuery object,
  // rather than the element.
  //
  $.fn.min$ = function (f) {
    if (typeof f == "string") f = $.fn[f];
    return Math.min(this.map$(f).toArray());
  };

  // Returns the maximum of the given function applied to each element in the selection.
  // Resolves `f` as a jQuery method if it's a string.
  //
  $.fn.max = function (f) {
    if (typeof f == "string") return this.max$(f);
    return Math.max(this.map(f).toArray());
  };

  // Alternative form of `max`, applies the given function in the context of the jQuery object,
  // rather than the element.
  //
  $.fn.max$ = function (f) {
    if (typeof f == "string") f = $.fn[f];
    return Math.max(this.map$(f).toArray());
  };

  ///////////////////////////////////////////////////////////////////////////////
  // Metadata selectors /////////////////////////////////////////////////////////

  var pseudo = $.expr[":"];

  // The :data selector filters for elements with non-null object at `path`

  // var data = pseudo.data = function (el, path)
  // {
  //   var $el = $ (el), val = $el.data (), keys = path.match (/\w+/g), key
  //   while (key = keys.shift ())
  //     if (! (val = maybeOf (val [key]))) return val
  //   return val
  // }

  // The :on(type) selector filters for elements with an event triggered by `type`
  //
  var on = (pseudo.on = function (el, i, m) {
    return $(el).handlersOn(m[3]).length;
  });

  ///////////////////////////////////////////////////////////////////////////////
  // Link selectors /////////////////////////////////////////////////////////////

  // The :link(type) selector filters for links generally with an `href` matching `type`,
  // otherwise as defined below
  //
  var link = (pseudo.link = function (el, i, m) {
    var $el = $(el),
      href = $el.attr("href"),
      sel = m[3];
    if (!$el.is("a")) return false;
    if (!sel) return true;

    var or = sel.split(/\s*,\s*/);
    or: for (var i = 0; i < or.length; i++) {
      var and = or[i].match(/\S+/g);
      and: for (var j = 0; j < and.length; j++) {
        if (link.hasOwnProperty(and[j])) {
          switch (TypeOf(link[and[j]])) {
            case "RegExp":
              if (link[and[j]].test(href)) continue and;
              continue or;

            case "Function":
              if (link[and[j]]($el, href, sel)) continue and;
              continue or;

            default:
              continue or;
          }
        } else if (!new RegExp(and[j]).test(href)) continue or;
      }
      return true;
    }
    return false;
  });

  link["^"] = link.local = /^[^:]+$/; // matches local links
  link[":"] = link.scheme = /^\w+:/; // matches links with a scheme
  link["."] = link.relative = /^[^\/][^:]+$/; // matches relative links
  link["/"] = link.absolute = /^[\/]/; // matches absolute links
  link["@"] = link.mail = /^mailto:/; // matches mail links

  link.ftp = function (
    $el,
    href // matches ftp links
  ) {
    return $el.is(":link(ftp:)");
  };

  link.http = function (
    $el,
    href // matches http links
  ) {
    return $el.is(":link(^, http:)");
  };

  link.file = function (
    $el,
    href // matches file links
  ) {
    return (
      $el.is(":link(http, ftp)") &&
      /\.\w+$/.test(href) &&
      !/\.html?$/.test(href)
    );
  };

  link.bound = function (
    $el // matches links with bindings
  ) {
    return $el.is(":on(click)");
  };

  link.unbound = function (
    $el // matches links without bindings
  ) {
    return !link.bound($el);
  };

  link.internal = function (
    $el // matches internal links
  ) {
    return $el.is(":link(^), :link(" + window.location.host + ")");
  };

  link.external = function (
    $el // matches external links
  ) {
    return !link.internal($el);
  };
})(jQuery);
