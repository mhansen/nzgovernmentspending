dollars_per_person = (dollars_per_country_thousands) ->
  NZ_POPULATION = 4405193 # hardcoded - from the Statistics NZ Population Clock.
  1000 * dollars_per_country_thousands / NZ_POPULATION

plot = (depts_data) ->
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
        data: depts_data
        size: "100%"
    } ]
    plotOptions:
      pie:
        allowPointSelect: true
        cursor: "pointer"
        dataLabels:
          formatter: ->
              @point.name.replace /(\w+ \w+)/g, "$1<br/>"  if @percentage > 5
          distance: -70
          style:
            font: "normal 11px sans-serif"
          y: -4
        point: events:
          select: (event) ->
            dept_expense_series = expense_series_for_dept @name

            view_dept_pie @name, dept_expense_series, calculate_dept_percent_change(@name)
            view_dept_receipt dept_expense_series

            $.ajax "/gen204?" + @name # log the click
  }

view_dept_receipt = (dept_data) ->
  $("#detail_receipt table").remove()
  $("#receipt_header").text "Per Capita Tax Receipt"
  $list = $("<table>").appendTo("#detail_receipt")
  $.each dept_data, (i, subdept) ->
    color = (if (subdept["percentChange"] < 0) then "pink" else "limegreen")
    $("<tr class='lineitem'>").
        append($("<td class='expense'>").
                 text("$" + dollars_per_person(subdept["y"]).toFixed(2))).
        append($("<td class='delta' style='padding-right:10px;text-align:right;'>").
                 html(format_percent(subdept["percentChange"]))).
        append($("<td class='description'>").
                 text(subdept["name"])).
        appendTo $list
  
  $("td.delta").attr "title", "Percentage change over last year's Budget"

format_percent = (n) ->
  return ""  if n == undefined
  num_decimal_points = (if (Math.abs(n) < 10) then 1 else 0)
  s = Math.abs(n).toFixed(num_decimal_points) + "%"
  s = "(<span style='color:red;'>⇩" + s + "</span>)" if n < -0.05 # decrease in funding
  s = "(<span style='color:limegreen;'>⇧" + s + "</span>)" if n > 0.05 # increase in funding
  s

calculate_dept_percent_change = (dept_name) ->
  dept = model.dept_totals[dept_name]
  100 * ((dept.nzd - dept.previous_nzd) / dept.nzd)

view_dept_pie = (dept_name, dept_data, dept_percent_change) ->
  $("#detail_delta_percent").html format_percent(dept_percent_change)
  $("#detail_delta_caption").text "over last year"
  dept_chart.destroy() if dept_chart
  dept_chart = new Highcharts.Chart {
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

# Long sentences aren't autowrapped by the highcharts library, and they go over
# the edges of the graph and get clipped. This looks horrible; we have to wrap
# them ourselves.
split_long_sentence = (sentence, joiner) ->
  sentence.replace /([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner

format_tooltip = ->
  @point.name.replace()
  perperson = "$" + dollars_per_person(@y).toFixed(2) + " per capita."
  total = "$" + (@y / 1000000).toFixed(2) + " Billion "
  splitName = "<b>" + split_long_sentence(@point.name, "<br/><b>")
  percentage = "<i>(" + ((@y / model.grand_total.nzd) * 100).toFixed(2) + "% of total)</i>"
  splitName + "<br/>" + total + percentage + "<br/>" + perperson

model = {}

expense_series_for_dept = (dept_name) ->
  series = []
  for lineItemName, item of model.budget[dept_name]
    if item.nzd
      series.push {
        name: lineItemName
        y: item.nzd
        percentChange: 100 * ((item.nzd - item.previous_nzd) / item.nzd) if item.previous_nzd
        scope: item.scope
      }
  series.sort (a, b) -> b['y'] - a['y']
  series

expense_series_for_all_depts = (budget) ->
  series = []
  for name, dept_expenses of budget
    sum = 0
    for subdept_name, item of dept_expenses
      sum += item.nzd if item.nzd
    series.push [ name, sum ]
  series.sort (a, b) -> b[1] - a[1]
  series

dept_chart = undefined
viewing_income = $.url.param("income") == "true"

$ ->
  $("a#inline").fancybox()
  # update links
  if viewing_income
    filename_to_fetch = "incomes-2011.json"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a>" +
                                   " ● <b>Viewing Incomes</b>"
  else
    filename_to_fetch = "expenses-2011.json"
    $("#incomes_or_expenses").html "<b>Viewing Expenses</b>" +
                                   " ● <a href='/?income=true'>View Incomes</a>"
  # plot the data
  $.getJSON filename_to_fetch, (fetched_data) ->
    model = fetched_data
    plot expense_series_for_all_depts(model.budget)
