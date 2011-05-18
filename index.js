var raw_expenses;
var main_chart;
var detail_chart;
var expense_series_by_dept = {};

function dollars_per_person(dollars_per_country_thousands) {
    var NZ_POPULATION = 4405193; // From Statistics NZ Population Counter.
    return "$" + (1000 * dollars_per_country_thousands / NZ_POPULATION).toFixed(2);
}

$(function () {
    $.getJSON("expenses-2011.json", function (budget) {
        raw_expenses = budget;

        $.each(raw_expenses, function (dept_name, dept_expenses) {
            expense_series_by_dept[dept_name] = [];
            $.each(dept_expenses, function (subdept_name, subdept_expense) {
                expense_series_by_dept[dept_name].push([subdept_name, subdept_expense]);
            });
            expense_series_by_dept[dept_name].sort(function (a, b) {
                return b[1] - a[1];
            });
        });

        plot(expense_series_for_all_depts(raw_expenses));
    });
});

function expense_series_for_all_depts(budget) {
    var expense_series = [];
    $.each(budget, function (name, dept_expenses) {
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
            backgroundColor: null
        },
        credits: {
            enabled: false
        },
        title: {
            text: 'All Departments',
            margin: 20,
            style: {
                "fontSize": "16px",
                "font-family": "Helvetica, Arial, sans-serif"
            }
        },
        tooltip: {
            formatter: format_tooltip
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    formatter: function () {
                        if (this.percentage > 4) {
                            return this.point.name.replace(/(\w+ \w+)/g, "$1<br/>");
                        }
                    },
                    distance: -70,
                    style: {
                        "font": "normal 11px sans-serif"
                    },
                    y: -4
                },
                point: {
                    events: {
                        select: function (event) {
                            plot_detail_pie(this.name);
                            fill_detail_receipt(this.name);
                        },
                        unselect: function (event) {
                        }
                    }
                }
            }
        },
        legend: {
            enabled: false,
        },
        series: [{
            type: 'pie',
            name: 'Government Expenses',
            data: depts_data,
            size: "100%"
        }]
    });
    console.log(main_chart)
}

function fill_detail_receipt(dept_name) {
    var dept_data = expense_series_by_dept[dept_name];
    $("#detail_receipt table").remove();
    $("#receipt_header").text("Your Receipt");
    var $list = $("<table>").appendTo("#detail_receipt");

    $.each(dept_data, function (i, subdept) {

        $("<tr class='lineitem'>").
            append($("<td class='expense'>").text(dollars_per_person(subdept[1]))).
            append($("<td class='description'>").text(subdept[0])).
                appendTo($list);
    });
}

function plot_detail_pie(dept_name) {
    var dept_data = expense_series_by_dept[dept_name];
    if (detail_chart) {
        detail_chart.destroy();
    }
    detail_chart = new Highcharts.Chart({
        chart: {
            renderTo: "detail_container",
            backgroundColor: null
        },
        credits: {
            enabled: false
        },
        title: {
            text: dept_name,
            margin: 20,
            style: {
                "fontSize": "16px",
                "font-family": "Helvetica, Arial, sans-serif"
            }
        },
        series: [{
            type: 'pie',
            name: 'Detail Expenses',
            data: dept_data
        }],
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: false
                },
                innerSize: 150,
                size: "100%"
            }
        },
        tooltip: {
            formatter: format_tooltip
        }
    });
}

function format_tooltip() {
    var perperson = dollars_per_person(this.y) + " per person.";
    var total = "$" + (this.y / 1000000).toFixed(2) + " Billion";
    var splitName = '<b>'+this.point.name.split(" - ").join("<br/><b>");
    return splitName +'<br/>'+ total + '<br/>' + perperson;
}
