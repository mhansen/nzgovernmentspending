// Format a percentage for display, with colors and an arrow pointing up or down.
let format_percent = function (n) {
  if (n === undefined) { return ""; }
  // Round to 2 significant figures - JavaScript doesn't have a
  // builtin function for this.
  let num_decimal_points = ((Math.abs(n) < 10) ? 1 : 0);
  let s = Math.abs(n).toFixed(num_decimal_points) + "%";
  if (n < -0.05) {
    // Show a significant funding decrease in red.
    return `(<span style='color:red;'>⇩${s}</span>)`;
  } else if (n > 0.05) {
    // Show a significant funding increase in green.
    return `(<span style='color:limegreen;'>⇧${s}</span>)`;
  } else {
    return s;
  }
};

// Long sentences aren't autowrapped by the highcharts library, and they go over
// the edges of the graph and get clipped. This looks horrible; we have to wrap
// them ourselves. Do this by splitting every fifth word.
let split_long_sentence = (sentence, joiner) => sentence.replace(/([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, `$1${joiner}`);

// A formatter function that gives the tooltip information when hovering over a
// pie slice. Returns some subsetted-HTML for HighCharts to convert into SVG.
let format_tooltip = function () {
  this.point.name.replace();
  let total = format_big_dollars(this.y);
  let splitName = `<b>${split_long_sentence(this.point.name, "<br/><b>")}`;
  let proportion_of_total = this.y / model.grand_total.nzd;
  let percentage = `<i>(${(proportion_of_total * 100).toFixed(2)}% of total)</i>`;
  let perperson = `$${dollars_per_person(this.y).toFixed(2)} per capita.`;
  let scope = (this.point.scope != null) ? this.point.scope : "";
  return splitName + "<br/>" + total + percentage + "<br/>" + perperson + "<br/>" + scope;
};

let format_big_dollars = function (big_dollars) {
  let a_billion = 1000000000;
  let a_million = 1000000;
  if (big_dollars > a_billion) {
    return `$${(big_dollars / a_billion).toFixed(2)} Billion `;
  } else {
    return `$${(big_dollars / a_million).toFixed(2)} Million `;
  }
};

// Hardcoded - from the Statistics NZ Population Clock.
let dollars_per_person = function (dollars_per_country) {
  const NZ_POPULATION = 4405193;
  return dollars_per_country / NZ_POPULATION;
};

// window.appModel - a convenient place to hold triggers
window.appModel = new Backbone.Model;

// Construct views
let accountLinksView = new AccountLinksView({ el: "#account_links" });
let govtPieView = new GovtPieView({ el: "#budget_container" });
let deptPieView = new DeptPieView({ el: "#dept_graph" });
let deptReceiptView = new DeptReceiptView({ el: "#receipt_wrapper" });

appModel.bind("change:viewingIncome", (model, viewingIncome) => accountLinksView.render(viewingIncome));

appModel.bind("dept_select", function (dept_name) {
  let d = model.dept_totals[dept_name];
  let dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd);

  appModel.set({ activeDept: dept_name });

  deptPieView.render(dept_name, model.series_for_dept[dept_name], dept_percent_change);
  deptReceiptView.render(model.series_for_dept[dept_name]);
});

appModel.bind("change:viewingIncome", function (m, viewingIncome) {
  // Fetch the file, save the model data, and plot the budget.
  let filename = viewingIncome ? "b13-revenue-data.json" : "b13-expenditure-data.json";
  $.getJSON(filename, function (fetched_data) {
    window.model = fetched_data;
    govtPieView.render(model.series_for_budget, viewingIncome, model.grand_total.nzd);
  });
});

$(document).ready(function () {
  $("a#creditslink").fancybox();
  // Are we looking at income or expenses? Fetch the right file, and
  // link to the other page.
  appModel.set({
    viewingIncome: $.url.param("income") === "true"
  });
});
