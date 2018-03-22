(function () {
// Main client-side logic for the wheresmytaxes site.

// window.appModel - a convenient place to hold triggers
window.appModel = new Backbone.Model;

// Construct views
let accountLinksView = new AccountLinksView({ el: "#account_links" });
let govtPieView = new GovtPieView({ el: "#budget_container" });
let deptPieView = new DeptPieView({ el: "#dept_graph" });
let deptReceiptView = new DeptReceiptView({ el: "#receipt_wrapper" });

// IE <9 and android <3.0 don't support SVG, so we can't render the charts. :(
if (!hasSvgSupport()) {
  alert("Sorry, your browser doesn't support inline SVG.\n" +
    "We can't show render the graphs without it."
  );
  return;
}

appModel.bind("change:viewingIncome", (model, viewingIncome) => accountLinksView.render(viewingIncome));

appModel.bind("dept_select", function (dept_name) {
  let d = model.dept_totals[dept_name];
  let dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd);

  appModel.set({ activeDept: dept_name });

  deptPieView.render(dept_name, model.series_for_dept[dept_name], dept_percent_change);
  return deptReceiptView.render(model.series_for_dept[dept_name]);
});

appModel.bind("change:viewingIncome", function (m, viewingIncome) {
  // Fetch the file, save the model data, and plot the budget.
  let filename = viewingIncome ? "b13-revenue-data.json" : "b13-expenditure-data.json";
  return $.getJSON(filename, function (fetched_data) {
    window.model = fetched_data;
    return govtPieView.render(model.series_for_budget, viewingIncome, model.grand_total.nzd);
  });
});

$(document).ready(function () {
  $("a#creditslink").fancybox();
  // Are we looking at income or expenses? Fetch the right file, and
  // link to the other page.
  return appModel.set({
    viewingIncome: $.url.param("income") === "true"
  });
});

})();
