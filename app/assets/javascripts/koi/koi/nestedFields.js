var $;

$ = jQuery;

$.fn.koiNestedFields = function () {
  var $this,
    attributeName,
    className,
    componentSelector,
    k,
    ks,
    max,
    min,
    n,
    opt,
    selector,
    tidyInsert,
    tidyRemove,
    _i,
    _len,
    _ref;
  $this = $(this);
  (_ref = $this.data()),
    (min = _ref.min),
    (max = _ref.max),
    (n = _ref.count),
    (className = _ref["class"]),
    (attributeName = _ref.attribute);
  selector = ".class-" + className + ".attribute-" + attributeName;
  componentSelector = "" + selector + ".nested-fields-";
  opt = {};
  ks = "container item empty add remove".split(" ");
  for (_i = 0, _len = ks.length; _i < _len; _i++) {
    k = ks[_i];
    opt["" + k + "Selector"] = componentSelector + k;
  }
  opt.itemTemplateSelector = componentSelector + "item-template";
  opt.emptyTemplateSelector = componentSelector + "empty-template";
  tidyInsert = function () {
    if (n >= max) {
      $(opt.addSelector, $this).hide();
    }
    if (n > min) {
      return $(opt.removeSelector, $this).show();
    }
  };
  tidyRemove = function () {
    if (n < max) {
      $(opt.addSelector, $this).show();
    }
    if (n <= min) {
      return $(opt.removeSelector, $this).hide();
    }
  };
  opt.beforeInsert = function (item, f) {
    if (!(n < max)) {
      return;
    }
    n += 1;
    tidyInsert();
    return f();
  };
  opt.beforeRemove = function (item, f) {
    if (!(n > min)) {
      return;
    }
    n -= 1;
    tidyRemove();
    return f();
  };
  $this.nestedFields(opt);
  while (n < min) {
    $this.nestedFields("insert");
  }
  tidyInsert();
  return tidyRemove();
};
