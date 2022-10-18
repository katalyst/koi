var $;

$ = jQuery;

$.fn.koiSortable = function () {
  return this.sortable({
    containment: "parent",
  });
};
