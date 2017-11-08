window.GovtPieView = Backbone.View.extend({
  render_title_text(viewing_income, grand_total) {
    // Add a comma before the last three numbers in the string.
    let add_comma_to_number_string = s => s.replace(/(\d{3})$/, ",$1");

    return `Government ${viewing_income ? "Incomes" : "Expenses"}: ` +
    "$" + add_comma_to_number_string(dollars_per_person(grand_total).toFixed(0)) +
    " per capita";
  },

  // Plot the main pie chart of all departments.
  render(budget_expense_series, viewing_income, grand_total) {
    return this.chart = new Highcharts.Chart({
      chart: {
        renderTo: this.el,
        backgroundColor: null
      },
      credits: {
        text: "[Budget 2013]",
        href: "http://www.treasury.govt.nz/"
      },
      title: {
        text: this.render_title_text(viewing_income, grand_total),
        margin: 20,
        style: {
          fontSize: "16px",
          "font-family": "Helvetica, Arial, sans-serif"
        }
      },
      tooltip: {
        formatter: format_tooltip
      },
      legend: {
        enabled: false
      },
      series: [ {
          type: "pie",
          data: budget_expense_series,
          size: "100%"
      } ],
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: "pointer",
          dataLabels: {
            formatter() {
              // Draw a label for only thick slices.
              if (this.percentage > 5.6) {
                // Split long labels every two words.
                return this.point.name.replace(/(\w+ \w+)/g, "$1<br/>");
              }
            },
            distance: -70,
            style: {
              font: "normal 11px sans-serif"
            },
            // A little nudging to keep text inside their slices.
            y: -4
          },
          point: { events: {
            mouseOver() { return appModel.trigger("dept_mouseover", this.name); },
            select() { return appModel.trigger("dept_select", this.name); }
          }
        }
        }
      }
    });
  }});
