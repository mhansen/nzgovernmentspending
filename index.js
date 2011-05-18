var NZ_POPULATION = 4405193;
var YEAR = 2011;
var raw_expenses;
var main_chart;
var detail_chart;
var expense_series_by_dept = {};

$(function () {
    $.getJSON("expenses.json", function (data) {
        raw_expenses = data;

        $.each(data[YEAR], function (dept_name, dept_expenses) {
            expense_series_by_dept[dept_name] = [];
            $.each(dept_expenses, function (subdept_name, subdept_expense) {
                expense_series_by_dept[dept_name].push([subdept_name, subdept_expense]);
            });
            expense_series_by_dept[dept_name].sort(function (a, b) {
                return b[1] - a[1];
            });
        });

        plot(expense_series_for_all_depts(data[YEAR]));
    });
});

function expense_series_for_all_depts(yearData) {
    var expense_series = [];
    $.each(yearData, function (name, dept_expenses) {
        var sum = 0;
        $.each(dept_expenses, function (subdept_name, cost) {
            sum += cost;
        });
        expense_series.push([name, sum]);
    });
    expense_series.sort(function (a, b) {
        return b[1] - a[1];
    });
    return expense_series;
}

function plot(depts_data) {
    main_chart = new Highcharts.Chart({
        chart: {
            renderTo: 'chart_container',
        },
        credits: {
            text: 'markhansen.co.nz/nzgovernmentspending',
            href: 'http://www.markhanmsen.co.nz/nzgovernmentspending'
        },
        title: {
            text: '',
        },
        tooltip: {
            formatter: function() {
                var perperson = "$" + (1000 * this.y / NZ_POPULATION).toFixed(2) 
                + " per person.";
                var total = "$" + (this.y / 1000000).toFixed(2) + " Billion";
                return '<b>'+ this.point.name +'</b><br>'+ total + '<br>' + perperson;
            }
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    formatter: function () {
                        if (this.percentage > 4) {
                            return this.point.name;
                        }
                    },
                    distance: -80,
                    style: {
                        "font": "normal 12px sans-serif"
                    }
                },
                point: {
                    events: {
                        select: function (event) {
                            plot_detail(expense_series_by_dept[this.name]);
                            console.log(this);
                            console.log(event);
                        },
                        unselect: function (event) {
                        }
                    }
                },
                showInLegend: true
            }
        },
        legend: {
            enabled: false,
        },
        series: [{
            type: 'pie',
            name: 'Government Expenses',
            data: depts_data
        }]
    });
}

function plot_detail(dept_data) {
    if (detail_chart) {
        detail_chart.destroy();
    }
    detail_chart = new Highcharts.Chart({
        chart: {
            renderTo: "detail_container",
        },
        title: {
            text: ''
        },
        series: [{
            type: 'pie',
            name: 'Detail Expenses',
            data: dept_data
        }],
        plotOptions: {
            pie: {
                dataLabels: {
                    enabled: false
                },
                innerSize: 150
            }
        },
        tooltip: {
            formatter: function() {
                var perperson = "$" + (1000 * this.y / NZ_POPULATION).toFixed(2) 
                + " per person.";
                var total = "$" + (this.y / 1000000).toFixed(2) + " Billion";
                return '<b>'+ this.point.name +'</b><br>'+ total + '<br>' + perperson;
            }
        },
    });
}
