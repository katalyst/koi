!(function ($) {
  $.fn.pop = Array.prototype.pop;

  $.fn.shift = Array.prototype.shift;

  $.fn.shiftString = function (defaults) {
    return typeof this[0] === "string" ? this.shift() : defaults;
  };

  $.fn.popOptions = function (defaults) {
    return $.extend(
      defaults || {},
      $.isPlainObject(this.last()) ? this.pop() : {}
    );
  };

  $.fn.withPop = function (predicate, f) {
    if (arguments.length === 1)
      [].unshift.call(arguments, function () {
        return true;
      });
    var n, t;
    if ((n = this.length) && (t = this[n - 1]) && predicate(t)) return t;
  };

  $.fn.appear = function () {
    return this.css({ visibility: "visible" });
  };

  $.fn.disappear = function () {
    return this.css({ visibility: "hidden" });
  };

  $.factory = {
    iframe: function () {
      var $arguments = $(arguments),
        opt = $arguments.popOptions(),
        src = $arguments.shiftString(opt.src);
      return $("<iframe>", $.extend(opt, { src: src, frameborder: 0 }))
        .disappear()
        .load(function () {
          var $iframe = $(this).appear();

          var contentDoc = $iframe.$contentDocument(),
            contentWidth = contentDoc.width(),
            contentHeight = contentDoc.height();
          $iframe.width(contentWidth).height(contentHeight);
        });
    },
  };
})(jQuery);

!(function ($, win) {
  // $.fn.document ////////////////////////////////////////////////////////////

  $.extend({
    // returns the `iframe` object for the current window
    parentFrame: function () {
      return $(window).parentFrame();
    },

    isAny: function (arg, f) {
      for (var i = 0; i < arg.length; i++) if (f(arg[i])) return true;
      return false;
    },

    isAll: function (arg, f) {
      for (var i = 0; i < arg.length; i++) if (!f(arg[i])) return false;
      return true;
    },

    isDocument: function (arg) {
      return arg != null && typeof arg.doctype === "object"; // dodgy!
    },

    isElement: function (arg) {
      return $.isSymbol(arg.tagName);
    },

    isNode: function (arg) {
      return $.isSymbol(arg.nodeName);
    },

    isSymbol: function (arg) {
      return typeof arg === "string" && arg.length > 0;
    },

    isEquivalence: function (arg) {
      for (var i = 1; i < arg.length; i++)
        if (arg[i] !== arg[i - 1]) return false;
      return true;
    },

    isNontrivialEquivalence: function (arg) {
      return arg.length && $.isEquivalence(arg);
    },
  });

  $.fn.extend({
    // .data is window specific, so we use .equalizeWindow to
    // make sure we are using the appropriate jQuery instance
    equalizeWindow: function () {
      var $windows = this.$window();
      return $.isNontrivialEquivalence($windows)
        ? $windows[0].jQuery(this.toArray())
        : this;
    },

    env: function (k) {
      if (k == null) {
        throw "not implemented";
      } else {
        var $this = $(this),
          got = $this.data(k);
        return typeof got === "undefined" ? $this.envParent().env(k) : got;
      }
    },

    $env: function (k) {
      return this.map(function () {
        return $(this).env(k);
      });
    },

    envParent: function () {
      return this.map(function () {
        var $this = $(this);
        return $.isWindow(this)
          ? $this.parentFrame()[0] || $this.parentWindow()
          : $this.parent()[0] || $this.window();
      }).equalizeWindow();
    },

    $envParent: function () {
      return this.envParent(); // just for naming consistency
    },

    parentWindow: function () {
      var win = $(this).window(),
        parent = win.parent;
      return parent === win ? undefined : parent;
    },

    $parentWindow: function () {
      return this.map(function () {
        return $(this).parentWindow();
      }).equalizeWindow();
    },

    parentDocument: function () {
      return this.$parentDocument()[0];
    },

    $parentDocument: function () {
      return this.$parentWindow().map(function () {
        return this.document;
      });
    },

    // returns the `frame` or `iframe` object for the window corresponding to the given element
    parentFrame: function () {
      return this.$parentWindow().map(function () {
        return this.jQuery("frame, iframe").filter(function () {
          return $(this).contentWindow() === win;
        })[0];
      });
    },

    $parentFrame: function () {
      return this.parentFrame(); // just for naming consistency
    },

    contentWindow: function () {
      return this.$contentWindow()[0];
    },

    $contentWindow: function () {
      return this.map(function () {
        return this.contentWindow || $(this.contentDocument).window();
      });
    },

    contentDocument: function () {
      return this.$contentDocument()[0];
    },

    $contentDocument: function () {
      return this.map(function () {
        return this.contentDocument || $(this.contentWindow).document();
      });
    },

    window: function () {
      return this.$window()[0];
    },

    $window: function () {
      return this.$document().map(function () {
        return this.defaultView || this.parentWindow;
      });
    },

    document: function () {
      return this.$document()[0];
    },

    $document: function () {
      return this.map(function () {
        return $.isDocument(this.ownerDocument)
          ? this.ownerDocument
          : $.isDocument(this)
          ? this
          : $.isWindow(this)
          ? this.document
          : undefined;
      });
    },

    // the rest doesn't really belong here, but we'll factor it out later.

    firstChild: function () {
      return this.children().first();
    },

    lastChild: function () {
      return this.children().last();
    },
  });
})(window.jQuery, window);
