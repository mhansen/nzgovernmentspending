DeptPieView = Backbone.View.extend({
  // Plot the smaller graph of items within a department.
  render(dept_name, dept_data, dept_percent_change) {
    $("#dept_delta_percent").html(format_percent(dept_percent_change));
    $("#dept_delta_caption").text("over last year");
    if (this.chart) { this.chart.destroy(); }
    this.chart = new Highcharts.Chart({
      chart: {
        renderTo: this.el,
        backgroundColor: null
      },
      credits: {
        enabled: false
      },
      title: {
        text: split_long_sentence(dept_name, "<br/>"),
        margin: 20,
        style: {
          fontSize: "16px",
          "font-family": "Helvetica, Arial, sans-serif",
          whiteSpace: 'normal !important',
          width: '300px'
        }
      },
      series: [{
        type: "pie",
        data: dept_data
      }],
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: "pointer",
          dataLabels: {
            enabled: false
          },
          innerSize: 150,
          size: "100%",
          point: {
            events: {
              mouseOver() { return appModel.trigger("subdept_mouseover", this.name); }
            }
          }
        }
      },
      tooltip: {
        formatter: format_tooltip,
        style: {
          whiteSpace: 'normal',
          width: '200px'
        }
      }
    });
  }
});
