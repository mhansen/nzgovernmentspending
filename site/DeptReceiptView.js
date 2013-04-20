
window.DeptReceiptView = Backbone.View.extend({
  render: function(series_for_dept) {
    debugger;
    var $list, item, percentChange, _i, _len;
    this.$(".receipt table").remove();
    this.$(".header").text("Per Capita Tax Receipt");
    this.$(".receipt").append("<table>");
    $list = this.$("table");
    for (_i = 0, _len = series_for_dept.length; _i < _len; _i++) {
      item = series_for_dept[_i];
      if (item.previous_y) {
        percentChange = 100 * ((item.y - item.previous_y) / item.previous_y);
      }
      $("<tr class='lineitem'>").append($("<td class='expense'>").text("$" + dollars_per_person(item.y).toFixed(2))).append($("<td class='delta' style='padding-right:10px;text-align:right;'>").html(format_percent(percentChange))).append($("<td class='description'>").text(item.name).attr("title", item.scope || "")).appendTo($list);
    }
    return this.$("td.delta").attr("title", "Percentage change over last year's Budget");
  }
});
