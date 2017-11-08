window.DeptReceiptView = Backbone.View.extend({
// Show a receipt-like view of a department's line items.
  render(series_for_dept) {
    this.$(".receipt table").remove();
    this.$(".header").text("Per Capita Tax Receipt");
    this.$(".receipt").append("<table>");

    let $list = this.$("table");
    for (let item of Array.from(series_for_dept)) {
      var percentChange;
      if (item.previous_y) {
        percentChange = 100 * ((item.y - item.previous_y) / item.previous_y);
      }
      $("<tr class='lineitem'>").
          append($("<td class='expense'>").
                  text(`$${dollars_per_person(item.y).toFixed(2)}`)).
          append($("<td class='delta' style='padding-right:10px;text-align:right;'>").
                  html(format_percent(percentChange))).
          append($("<td class='description'>")
            .text(item.name)
            .attr("title", item.scope || "")).
          appendTo($list);
    }
    return this.$("td.delta").attr("title", "Percentage change over last year's Budget");
  }
});
