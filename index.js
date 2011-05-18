var NZ_POPULATION = 4405193;

$(function () {
    $.getJSON("expenses.json", function (data) {
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
    });
});

function plot(data) {
    var chart;
    chart = new Highcharts.Chart({
        chart: {
            animation: false,
            renderTo: 'chart_container',
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            spacingTop: 0,
            spacingLeft: 0,
            spacingRight: 0,
            spacingBottom: 0
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
                        click: function (event) {
                            alert("You clicked: " + this.name);
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
            data: data
        }]
    });
}
