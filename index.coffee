# Main client-side logic for the wheresmytaxes site.
#
# Compile with coffeescript: `coffee -c index.coffee`

#### Controller
window.model = {}
$ ->
  $("a#creditslink").fancybox().on "click", ->
    mpq.track "Clicked Credits Button"
  # Are we looking at income or expenses? Fetch the right file, and link to the
  # other page.
  window.viewing_income = $.url.param("income") == "true"
  if viewing_income
    filename_to_fetch = "incomes-2011.json"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a>" +
                                   " ● <b>Viewing Incomes</b>"
    mpq.track "View Incomes"
  else
    filename_to_fetch = "expenses-2011.json"
    $("#incomes_or_expenses").html "<b>Viewing Expenses</b>" +
                                   " ● <a href='/?income=true'>View Incomes</a>"
    mpq.track "View Expenses"
  # Fetch the file, save the model data, and plot the budget.
  $.getJSON filename_to_fetch, (fetched_data) ->
    window.model = fetched_data
    view_budget model.series_for_budget
#### Views

# The main budget graph title changes 
view_budget_pie_title_text = (viewing_income, grand_total) ->
  # Add a comma before the last three numbers in the string.
  add_comma_to_number_string = (s) -> s.replace(/(\d{3})$/, ",$1")

  "Government " + (if viewing_income then "Incomes" else "Expenses") + ": " +
  "$" + add_comma_to_number_string(dollars_per_person(grand_total).toFixed(0)) +
  " per capita"

# Plot the main pie chart of all departments.
view_budget = (budget_expense_series) ->
  new Highcharts.Chart {
    chart:
      renderTo: "budget_container"
      backgroundColor: null
    credits:
      text: "[Budget 2011]"
      href: "http://www.treasury.govt.nz/"
    title:
      text: view_budget_pie_title_text viewing_income, model.grand_total.nzd
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
            $.ajax "/gen204?#{dept_name}"

            mpq.track "Opened a segment"
              viewing_income: viewing_income
              dept: dept_name
  }


dept_pie = undefined
# Plot the smaller graph of items within a department.
view_dept_pie = (dept_name, dept_data, dept_percent_change) ->
  $("#dept_delta_percent").html format_percent(dept_percent_change)
  $("#dept_delta_caption").text "over last year"
  dept_pie.destroy() if dept_pie
  dept_pie = new Highcharts.Chart {
    chart:
      renderTo: "dept_graph"
      backgroundColor: null
    credits:
      enabled: false
    title:
      text: split_long_sentence(dept_name, "<br/>")
      margin: 20
      style:
        fontSize: "16px"
        "font-family": "Helvetica, Arial, sans-serif"
        whiteSpace: 'normal !important'
        width: '300px'
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
      style:
        whiteSpace: 'normal'
        width: '200px'
  }

# Show a receipt-like view of a department's line items.
view_dept_receipt = (series_for_dept) ->
  $("#dept_receipt table").remove()
  $("#receipt_header").text "Per Capita Tax Receipt"
  $list = $("<table>").appendTo("#dept_receipt")
  for item in series_for_dept
    if item.previous_y
      percentChange = 100 * ((item.y - item.previous_y) / item.previous_y)
    $("<tr class='lineitem'>").
        append($("<td class='expense'>").
                text("$" + dollars_per_person(item.y).toFixed(2))).
        append($("<td class='delta' style='padding-right:10px;text-align:right;'>").
                html(format_percent(percentChange))).
        append($("<td class='description'>").text(item.name).attr("title", item.scope or "")).
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
  if n < -0.05
    # Show a decrease in funding in red.
    "(<span style='color:red;'>⇩" + s + "</span>)"
  else if n > 0.05
    # Show a funding increase in green.
    s = "(<span style='color:limegreen;'>⇧" + s + "</span>)"
  else
    s

# Long sentences aren't autowrapped by the highcharts library, and they go over
# the edges of the graph and get clipped. This looks horrible; we have to wrap
# them ourselves. Do this by splitting every fifth word.
split_long_sentence = (sentence, joiner) ->
  sentence.replace /([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner

# A formatter function that gives the tooltip information when hovering over a
# pie slice. Returns some subsetted-HTML for HighCharts to convert into SVG.
format_tooltip = ->
  @point.name.replace()
  total = format_big_dollars @y
  splitName = "<b>" + split_long_sentence(@point.name, "<br/><b>")
  proportion_of_total = @y / model.grand_total.nzd
  percentage = "<i>(" + (proportion_of_total * 100).toFixed(2) + "% of total)</i>"
  perperson = "$" + dollars_per_person(@y).toFixed(2) + " per capita."
  scope = if @point.scope? then @point.scope else ""
  splitName + "<br/>" + total + percentage + "<br/>" + perperson + "<br/>" + scope

format_big_dollars = (big_dollars) ->
  a_billion = 1000000000
  a_million = 1000000
  if big_dollars > a_billion
   "$" + (big_dollars / a_billion).toFixed(2) + " Billion "
  else
   "$" + (big_dollars / a_million).toFixed(2) + " Million "

# Hardcoded - from the Statistics NZ Population Clock.
dollars_per_person = (dollars_per_country) ->
  NZ_POPULATION = 4405193
  dollars_per_country / NZ_POPULATION

