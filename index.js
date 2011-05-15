var NZ_POPULATION = 4405193;

$(function () {
    $.getJSON("income.json", function (data) {
        var currentExpenses = data[2011];
        var treatedData = [];
        $.each(currentExpenses, function (name, deptExpenses) {
            var sum = 0;
            $.each(deptExpenses, function (subdeptname, cost) {
                sum += cost;
            });
            treatedData.push([name, sum]);
        });
        treatedData.sort(function (a, b) {
            return b[1] - a[1];
        });
        plot(treatedData);
        $('tspan').last().remove();
    });
});

function plot(data) {
    var chart;
    chart = new Highcharts.Chart({
        chart: {
            width: 800,
            height: 500,
            renderTo: 'chart_container',
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'NZ Government Income by departments'
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
                    enabled: false
                },
                events: {
                    click: function (event) {
                        var cost = event.point.y;
                        var text = "$" + (1000 * cost / NZ_POPULATION).toFixed(2) 
                                       + " per person.";
                        $("#chart_container").attr("title", text);
                        $("#chart_container").tooltip();
                    }
                },
                showInLegend: true
            }
        },
        legend: {
            layout: "vertical",
            align: "left",
            verticalAlign: "middle"
        },
        series: [{
            type: 'pie',
            name: 'Government Income',
            data: data
        }]
    });
}
