window.GovtPieView = Backbone.View.extend
  # Plot the main pie chart of all departments.
  render: (budget_expense_series) ->
    @chart = new Highcharts.Chart {
      chart:
        renderTo: @el
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
