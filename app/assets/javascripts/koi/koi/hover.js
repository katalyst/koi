var $,
  __slice = [].slice;

$ = jQuery;

$.fn.koiHover = function () {
  var args, delay, leave, over;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  delay = typeof args[0] === "number" ? args.shift() : 0;
  over = args.shift();
  leave = args.shift() || over;
  return this.each(
    (function (_this) {
      return function () {
        var nowHovering, nowRunning;
        nowRunning = false;
        nowHovering = false;
        _this.mouseover(function (e) {
          nowHovering = true;
          return $.delay(delay, function () {
            if (nowHovering) {
              nowRunning = true;
              return over.call(this, e);
            }
          });
        });
        return _this.mouseleave(function (e) {
          nowHovering = false;
          if (nowRunning) {
            nowRunning = false;
            return leave.call(this, e);
          }
        });
      };
    })(this)
  );
};
