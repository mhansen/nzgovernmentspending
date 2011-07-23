dollars_per_person = (dollars_per_country_thousands) ->
  NZ_POPULATION = 4405193
  1000 * dollars_per_country_thousands / NZ_POPULATION

expense_series_for_all_depts = (budget) ->
  expense_series = []
  $.each budget, (name, dept_expenses) ->
    sum = 0
    $.each dept_expenses, (subdept_name, cost) -> sum += cost
    expense_series.push [ name, sum ]
  expense_series.sort (a, b) -> b[1] - a[1]
  expense_series

plot = (depts_data) ->
  main_chart = new Highcharts.Chart {
    chart:
      renderTo: "chart_container"
      backgroundColor: null
    credits:
      text: "[Budget 2011]"
      href: "http://www.treasury.govt.nz/"
    title:
      text: "Government " + (if viewing_income then "Incomes" else "Expenses") + ": $" + dollars_per_person(total_expenses).toFixed(0).replace(/(\d{3})$/, ",$1") + " per capita"
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
            plot_detail_pie @name
            fill_detail_receipt @name
            $.ajax "/gen204?" + @name
  }

fill_detail_receipt = (dept_name) ->
  dept_data = expense_series_by_dept[dept_name]
  $("#detail_receipt table").remove()
  $("#receipt_header").text "Per Capita Tax Receipt"
  $list = $("<table>").appendTo("#detail_receipt")
  $.each dept_data, (i, subdept) ->
    color = (if (subdept["percentChange"] < 0) then "pink" else "limegreen")
    $("<tr class='lineitem'>").
        append($("<td class='expense'>").text("$" + dollars_per_person(subdept["y"]).toFixed(2))).
        append($("<td class='delta' style='padding-right:10px;text-align:right;'>").html(format_percent(subdept["percentChange"]))).
        append($("<td class='description'>").text(subdept["name"])).
        appendTo $list
  
  $("td.delta").attr "title", "Percentage change over last year's Budget"

format_percent = (n) ->
  return ""  if n == undefined
  num_decimal_points = (if (Math.abs(n) < 10) then 1 else 0)
  s = Math.abs(n).toFixed(num_decimal_points) + "%"
  s = "(<span style='color:red;'>⇩" + s + "</span>)" if n < -0.05 # decrease in funding
  s = "(<span style='color:limegreen;'>⇧" + s + "</span>)" if n > 0.05 # increase in funding
  s

calculateDeptPercentChange = (dept_name) ->
  return NaN  unless estimates_2011[dept_name]
  total_2011 = 0
  total_2012 = 0
  $.each estimates_2011[dept_name], (subdept_name, subdept_expense) ->
    total_2011 += subdept_expense
  
  $.each estimates_2012[dept_name], (subdept_name, subdept_expense) ->
    total_2012 += subdept_expense
  
  ((total_2012 - total_2011) / total_2011) * 100

plot_detail_pie = (dept_name) ->
  dept_data = expense_series_by_dept[dept_name]
  detail_chart.destroy()  if detail_chart
  dept_percent_change = calculateDeptPercentChange(dept_name)
  $("#detail_delta_percent").html format_percent(dept_percent_change)
  $("#detail_delta_caption").text "over last year"
  detail_chart = new Highcharts.Chart {
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

split_long_sentence = (sentence, joiner) ->
  sentence.replace /([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner

format_tooltip = ->
  @point.name.replace()
  perperson = "$" + dollars_per_person(@y).toFixed(2) + " per capita."
  total = "$" + (@y / 1000000).toFixed(2) + " Billion "
  splitName = "<b>" + split_long_sentence(@point.name, "<br/><b>")
  percentage = "<i>(" + ((@y / total_expenses) * 100).toFixed(2) + "% of total)</i>"
  splitName + "<br/>" + total + percentage + "<br/>" + perperson

estimates_2011 = undefined
estimates_2012 = undefined
main_chart = undefined
detail_chart = undefined
expense_series_by_dept = {}
total_expenses = 0
viewing_income = $.url.param("income") == "true"

$ ->
  if viewing_income
    filename_to_fetch = "incomes-2011and2012.json"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a> ● <b>Viewing Incomes</b>"
  else
    filename_to_fetch = "expenses-2011and2012.json"
    $("#incomes_or_expenses").html "<b>Viewing Expenses</b> ● <a href='/?income=true'>View Incomes</a>"

  $.getJSON filename_to_fetch, (budget) ->
    estimates_2011 = budget[2011]
    estimates_2012 = budget[2012]
    $.each estimates_2012, (dept_name, dept_expenses) ->
      expense_series_by_dept[dept_name] = []
      $.each dept_expenses, (subdept_name, subdept_expense) ->
        if estimates_2011[dept_name]
          lastYearExpense = estimates_2011[dept_name][subdept_name] or 0
          thisYearExpense = estimates_2012[dept_name][subdept_name]
          subDeptPercentChange = ((thisYearExpense - lastYearExpense) / lastYearExpense) * 100  unless lastYearExpense == 0
        expense_series_by_dept[dept_name].push {
          name: subdept_name
          y: subdept_expense
          percentChange: subDeptPercentChange
        }
        
        total_expenses += subdept_expense
      
      expense_series_by_dept[dept_name].sort (a, b) ->
        b["y"] - a["y"]
    
    plot expense_series_for_all_depts(estimates_2012)
  
  $("a#inline").fancybox()
