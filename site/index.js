(function() {
  var accountLinksView, deptPieView, deptReceiptView, govtPieView;

  if (document.location.hostname === "localhost") {
    mpq.track = function() {
      return console.log("tracking:", arguments);
    };
    mpq.register = function() {
      return console.log("registering:", arguments);
    };
  }

  window.appModel = new Backbone.Model;

  accountLinksView = new AccountLinksView({
    el: "#account_links"
  });

  govtPieView = new GovtPieView({
    el: "#budget_container"
  });

  deptPieView = new DeptPieView({
    el: "#dept_graph"
  });

  deptReceiptView = new DeptReceiptView({
    el: "#receipt_wrapper"
  });

  if (!hasSvgSupport()) {
    alert("Sorry, your browser doesn't support inline SVG.\n" + "We can't show render the graphs without it.");
    return;
  }

  appModel.bind("change:viewingIncome", function(model, viewingIncome) {
    return accountLinksView.render(viewingIncome);
  });

  appModel.bind("dept_select", function(dept_name) {
    var d, dept_percent_change;
    d = model.dept_totals[dept_name];
    dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd);
    appModel.set({
      activeDept: dept_name
    });
    deptPieView.render(dept_name, model.series_for_dept[dept_name], dept_percent_change);
    return deptReceiptView.render(model.series_for_dept[dept_name]);
  });

  appModel.bind("change:viewingIncome", function(m, viewingIncome) {
    var filename;
    filename = viewingIncome ? "b13-revenue-data.json" : "b13-expenditure-data.json";
    return $.getJSON(filename, function(fetched_data) {
      window.model = fetched_data;
      return govtPieView.render(model.series_for_budget, viewingIncome, model.grand_total.nzd);
    });
  });

  $(document).ready(function() {
    $("a#creditslink").fancybox();
    return appModel.set({
      viewingIncome: $.url.param("income") === "true"
    });
  });

}).call(this);
