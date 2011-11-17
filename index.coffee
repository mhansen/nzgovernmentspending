# Main client-side logic for the wheresmytaxes site.
#
# Compile with coffeescript: `coffee -c index.coffee`

if document.location.hostname == "localhost"
  mpq.track = -> console.log arguments

window.events = new Backbone.Model

events.bind "page_load", (type, filename) ->
  # Fetch the file, save the model data, and plot the budget.
  $.getJSON filename, (fetched_data) ->
    window.model = fetched_data
    view_budget model.series_for_budget

#### Controller
window.model = {}
$ ->
  $("a#creditslink").fancybox().on "click", ->
    mpq.track "Clicked Credits Button"
  # Are we looking at income or expenses? Fetch the right file, and link to the
  # other page.
  window.viewing_income = $.url.param("income") == "true"

  # IE <9 and android <3.0 don't support SVG, so we can't render the charts. :(
  if not hasSvgSupport()
    alert "Sorry, your browser doesn't support inline SVG.\n" +
          "We can't show render the graphs without it."
    return

  if viewing_income
    events.trigger "page_load", "Incomes", "incomes-2011.json"
  else
    events.trigger "page_load", "Expenses", "expenses-2011.json"

events.bind "page_load", (type) ->
  if type = "Incomes"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a>" +
                                   " ● <em>Viewing Incomes</em>"
  else
    $("#incomes_or_expenses").html "<em>Viewing Expenses</em>" +
                                   " ● <a href='/?income=true'>View Incomes</a>"

#### Views

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
          mouseOver: -> events.trigger "dept_mouseover", @name
          select: -> events.trigger "dept_select", @name
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
        point:
          events:
            mouseOver: -> events.trigger "subdept_mouseover", @name
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


events.bind "dept_select", (dept_name) ->
  d = model.dept_totals[dept_name]
  dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd)
  view_dept_pie dept_name, model.series_for_dept[dept_name], dept_percent_change
  view_dept_receipt model.series_for_dept[dept_name]
