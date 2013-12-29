window.DeptReceiptView = Backbone.View.extend
# Show a receipt-like view of a department's line items.
  render: (series_for_dept) ->
    @$(".receipt table").remove()
    @$(".header").text "Per Capita Tax Receipt"
    @$(".receipt").append("<table>")

    $list = @$("table")
    for item in series_for_dept
      if item.previous_y
        percentChange = 100 * ((item.y - item.previous_y) / item.previous_y)
      $("<tr class='lineitem'>").
          append($("<td class='expense'>").
                  text("$" + dollars_per_person(item.y).toFixed(2))).
          append($("<td class='delta' style='padding-right:10px;text-align:right;'>").
                  html(format_percent(percentChange))).
          append($("<td class='description'>")
            .text(item.name)
            .attr("title", item.scope or "")).
          appendTo $list
    @$("td.delta").attr "title", "Percentage change over last year's Budget"
