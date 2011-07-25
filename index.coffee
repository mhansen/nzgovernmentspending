## Main client-side logic for the wheresmytaxes site.
#
# Compile with coffeescript: `coffee -c index.coffee`
#
#### Views

view_budget = (budget_expense_series) ->
  new Highcharts.Chart {
    chart:
      renderTo: "chart_container"
      backgroundColor: null
    credits:
      text: "[Budget 2011]"
      href: "http://www.treasury.govt.nz/"
    title:
      text: "Government " + (if viewing_income then "Incomes" else "Expenses") + ": $" + dollars_per_person(model.grand_total.nzd).toFixed(0).replace(/(\d{3})$/, ",$1") + " per capita"
      margin: 20
      style:
        fontSize: "16px"
        "font-family": "Helvetica, Arial, sans-serif"
    tooltip:
      formatter: format_tooltip
    legend:
      enabled: false
    series: [ {
        type: "pie"
        data: budget_expense_series
        size: "100%"
    } ]
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: "pointer"
        dataLabels:
          formatter: ->
            # Draw a label for only thick slices.
            if @percentage > 5
              # Split long labels every two words.
              @point.name.replace /(\w+ \w+)/g, "$1<br/>"
          distance: -70
          style:
            font: "normal 11px sans-serif"
          # A little nudging to keep text inside their slices.
          y: -4
        point: events:
          select: (event) ->
            dept_name = @name
            dept_expense_series = model.series_for_dept[dept_name]

            d = model.dept_totals[dept_name]
            dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd)

            view_dept_pie dept_name, dept_expense_series, dept_percent_change

            view_dept_receipt model.series_for_dept[dept_name]

            # Log which department was clicked on, for statistics.
            $.ajax "/gen204?" + dept_name
  }

dept_pie = undefined
view_dept_pie = (dept_name, dept_data, dept_percent_change) ->
  $("#detail_delta_percent").html format_percent(dept_percent_change)
  $("#detail_delta_caption").text "over last year"
  dept_pie.destroy() if dept_pie
  dept_pie = new Highcharts.Chart {
    chart:
      renderTo: "detail_graph"
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: split_long_sentence(dept_name, "<br/>")
      margin: 20
      style:
        fontSize: "16px"
        "font-family": "Helvetica, Arial, sans-serif"
    series: [ {
      type: "pie"
      data: dept_data
    } ]
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: "pointer"
        dataLabels:
          enabled: false
        innerSize: 150
        size: "100%"
    tooltip:
      formatter: format_tooltip
  }

view_dept_receipt = (series_for_dept) ->
  $("#detail_receipt table").remove()
  $("#receipt_header").text "Per Capita Tax Receipt"
  $list = $("<table>").appendTo("#detail_receipt")
  for item in series_for_dept
    if item.previous_y
      percentChange = 100 * ((item.y - item.previous_y) / item.previous_y)
    $("<tr class='lineitem'>").
        append($("<td class='expense'>").
                text("$" + dollars_per_person(item.y).toFixed(2))).
        append($("<td class='delta' style='padding-right:10px;text-align:right;'>").
                html(format_percent(percentChange))).
        append($("<td class='description'>").
                text(item.name).attr("title", item.scope)).
        appendTo $list
  $("td.delta").attr "title", "Percentage change over last year's Budget"

#### Helper Methods

# Format a percentage for display, with colors and an arrow pointing up or down.
format_percent = (n) ->
  return ""  if n == undefined
  # Round to 2 significant figures - JavaScript doesn't have a
  # builtin function for this.
  num_decimal_points = (if (Math.abs(n) < 10) then 1 else 0)
  s = Math.abs(n).toFixed(num_decimal_points) + "%"
  # Show a decrease in funding in red.
  s = "(<span style='color:red;'>⇩" + s + "</span>)" if n < -0.05
  # Show a funding increase in green.
  s = "(<span style='color:limegreen;'>⇧" + s + "</span>)" if n > 0.05
  s

# Long sentences aren't autowrapped by the highcharts library, and they go over
# the edges of the graph and get clipped. This looks horrible; we have to wrap
# them ourselves.
split_long_sentence = (sentence, joiner) ->
  # Split every five words
  sentence.replace /([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner

format_tooltip = ->
  @point.name.replace()
  perperson = "$" + dollars_per_person(@y).toFixed(2) + " per capita."
  total = "$" + (@y / 1000000000).toFixed(2) + " Billion "
  splitName = "<b>" + split_long_sentence(@point.name, "<br/><b>")
  percentage = "<i>(" + ((@y / model.grand_total.nzd) * 100).toFixed(2) + "% of total)</i>"
  splitName + "<br/>" + total + percentage + "<br/>" + perperson

dollars_per_person = (dollars_per_country) ->
  # Hardcoded - from the Statistics NZ Population Clock.
  NZ_POPULATION = 4405193
  dollars_per_country / NZ_POPULATION

model = {}
viewing_income = $.url.param("income") == "true"

#### Controller
$ ->
  $("a#inline").fancybox()
  # Are we looking at income or expenses? Fetch the right file, and link to the
  # other page.
  if viewing_income
    filename_to_fetch = "incomes-2011.json"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a>" +
                                   " ● <b>Viewing Incomes</b>"
  else
    filename_to_fetch = "expenses-2011.json"
    $("#incomes_or_expenses").html "<b>Viewing Expenses</b>" +
                                   " ● <a href='/?income=true'>View Incomes</a>"
  # Fetch the file, save the model data, and plot the budget.
  $.getJSON filename_to_fetch, (fetched_data) ->
    model = fetched_data
    view_budget model.series_for_budget
