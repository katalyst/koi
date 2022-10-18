var $,
  __slice = [].slice;

$ = jQuery;

$.extend($, {
  application: function () {
    var args, e, f, _i;
    (args =
      2 <= arguments.length
        ? __slice.call(arguments, 0, (_i = arguments.length - 1))
        : ((_i = 0), [])),
      (f = arguments[_i++]);
    try {
      return f.apply(this, args);
    } catch (_error) {
      e = _error;
      if ($.application.debug) {
        throw e;
      }
    }
  },
});

$.extend($.fn, {
  application: function () {
    var args, f, fStar, live;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    live = typeof args[0] === "boolean" ? args.shift() : false;
    f = args[0];
    fStar = function () {
      return $(this).each(function (i, e) {
        return $.application.call(e, $(e), f);
      });
    };
    $(
      (function (_this) {
        return function () {
          if (live) {
            return _this.liveQuery(fStar);
          } else {
            return fStar.call(_this);
          }
        };
      })(this)
    );
    return this;
  },
  components: function () {
    var $components, args, f, live, selector;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    live = typeof args[0] === "boolean" ? args.shift() : false;
    (selector = args[0]), (f = args[1]);
    $components = this.find(selector).filter(
      (function (_this) {
        return function (i, e) {
          return $(e).isComponentOf(_this);
        };
      })(this)
    );
    if (f) {
      $components.application(live, f);
    }
    return $components;
  },
  isComponentOf: function (object) {
    return $(this).componentOf()[0] === $(object)[0];
  },
  componentOf: function () {
    var $parent;
    $parent = this;
    while (($parent = $parent.parent()).length) {
      if ($parent.hasClass("application")) {
        return $parent;
      }
    }
    return $();
  },
});

$.fn.component = $.fn.components;
// RunLink
