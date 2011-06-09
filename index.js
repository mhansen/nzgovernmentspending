var estimates_2011;
var estimates_2012;
var main_chart;
var detail_chart;
var expense_series_by_dept = {};
var total_expenses = 0;
var viewing_income = $.url.param("income") == "true";

function dollars_per_person(dollars_per_country_thousands) {
    var NZ_POPULATION = 4405193; // From Statistics NZ Population Counter.
    return (1000 * dollars_per_country_thousands / NZ_POPULATION);
}

$(function () {
    if (viewing_income) {
        var filename_to_fetch = "incomes-2011and2012.json";
        $("#incomes_or_expenses").html("<a href='/?income=false'>View Expenses</a> \u25CF <b>Viewing Incomes</b>");
    } else {
        var filename_to_fetch = "expenses-2011and2012.json";
        $("#incomes_or_expenses").html("<b>Viewing Expenses</b> \u25CF <a href='/?income=true'>View Incomes</a>");
    }
    $.getJSON(filename_to_fetch, function (budget) {
        estimates_2011 = budget[2011];
        estimates_2012 = budget[2012];

        $.each(estimates_2012, function (dept_name, dept_expenses) {
            expense_series_by_dept[dept_name] = [];
            $.each(dept_expenses, function (subdept_name, subdept_expense) {
                if (estimates_2011[dept_name]) {
                    var lastYearExpense = estimates_2011[dept_name][subdept_name] || 0;
                    var thisYearExpense = estimates_2012[dept_name][subdept_name];

                    if (lastYearExpense != 0) {
                        var subDeptPercentChange = ((thisYearExpense - lastYearExpense) / lastYearExpense) * 100;
                    }
                }

                expense_series_by_dept[dept_name].push({
                    name: subdept_name, 
                    y: subdept_expense,
                    percentChange: subDeptPercentChange
                });

                total_expenses += subdept_expense;
            });
            expense_series_by_dept[dept_name].sort(function (a, b) {
                return b['y'] - a['y'];
            });
        });

        plot(expense_series_for_all_depts(estimates_2012));
    });
    $("a#inline").fancybox();
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
            text: "[Budget 2011]",
            href: "http://www.treasury.govt.nz/"
        },
        title: {
            text: 'Government ' + 
                  (viewing_income ? 'Incomes' : 'Expenses') + ": $" +
                      dollars_per_person(total_expenses).toFixed(0).replace(/(\d{3})$/, ",$1") + 
                          " per capita",
                  //': $' + (total_expenses / 1000000).toFixed(2) + ' Billion',
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
                        if (this.percentage > 5) {
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
                            $.ajax("/gen204?" + this.name)
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
            data: depts_data,
            size: "100%"
        }]
    });
}

function fill_detail_receipt(dept_name) {
    var dept_data = expense_series_by_dept[dept_name];
    $("#detail_receipt table").remove();
    $("#receipt_header").text("Per Capita Tax Receipt");
    var $list = $("<table>").appendTo("#detail_receipt");

    $.each(dept_data, function (i, subdept) {

        var color = (subdept['percentChange'] < 0) ? 'red' : 'limegreen';

        $("<tr class='lineitem'>").
            append($("<td class='expense'>").text("$" + dollars_per_person(subdept['y']).toFixed(2))).
            append($("<td class='delta' style='padding-right:10px;text-align:right;'>").html(format_percent(subdept['percentChange']))).
            append($("<td class='description'>").text(subdept['name'])).
                appendTo($list);
    });
    $("td.delta").attr('title', 'Percentage change over last year\'s Budget');
}

function format_percent(n) {
    if (n === undefined) return "";

    var dp = (Math.abs(n) < 10) ? 1 : 0;
    var s = Math.abs(n).toFixed(dp) + "%";

    if (n < -0.05) {
        s = "<span style='color:red;'>\u21e9" + s + "</span>";
    }
    if (n > 0.05) {
        s = "<span style='color:limegreen;'>\u21e7" + s + "</span>";
    }

    return s;
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
            text: wrap_long_sentence(dept_name, "<br/>"),
            margin: 20,
            style: {
                "fontSize": "16px",
                "font-family": "Helvetica, Arial, sans-serif"
            }
        },
        series: [{
            type: 'pie',
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


function wrap_long_sentence(sentence, replacer) {
    return sentence.replace(/([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + replacer);
}

function format_tooltip() {
     this.point.name.replace();
    var perperson = "$" + dollars_per_person(this.y).toFixed(2) + " per capita.";
    var total = "$" + (this.y / 1000000).toFixed(2) + " Billion ";
    // long line items suck. break after 8 words
    var splitName = '<b>' + wrap_long_sentence(this.point.name, "<br/><b>");
    var percentage = "<i>(" +((this.y / total_expenses) * 100).toFixed(2) + "% of total)</i>";
    return splitName +'<br/>'+ total + percentage + '<br/>' + perperson;
}
