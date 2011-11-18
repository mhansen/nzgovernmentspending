# Main client-side logic for the wheresmytaxes site.

if document.location.hostname == "localhost"
  mpq.track = -> console.log "tracking:", arguments
  mpq.register = -> console.log "registering:", arguments

# window.appModel - a convenient place to hold triggers
window.appModel = new Backbone.Model

# Construct views
accountLinksView = new AccountLinksView el: "#account_links"
govtPieView = new GovtPieView el: "#budget_container"
deptPieView = new DeptPieView el: "#dept_graph"
deptReceiptView = new DeptReceiptView el: "#receipt_wrapper"

# IE <9 and android <3.0 don't support SVG, so we can't render the charts. :(
if not hasSvgSupport()
  alert "Sorry, your browser doesn't support inline SVG.\n" +
        "We can't show render the graphs without it."
  return

appModel.bind "change:viewingIncome", (model, viewingIncome) ->
  accountLinksView.render viewingIncome

appModel.bind "dept_select", (dept_name) ->
  d = model.dept_totals[dept_name]
  dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd)

  deptPieView.render dept_name, model.series_for_dept[dept_name], dept_percent_change
  deptReceiptView.render model.series_for_dept[dept_name]

appModel.bind "change:viewingIncome", (m, viewingIncome) ->
  # Fetch the file, save the model data, and plot the budget.
  filename = if viewingIncome then "incomes-2011.json" else "expenses-2011.json"
  $.getJSON filename, (fetched_data) ->
    window.model = fetched_data
    govtPieView.render model.series_for_budget, viewingIncome, model.grand_total.nzd

$("a#creditslink").fancybox()
# Are we looking at income or expenses? Fetch the right file, and link to the
# other page.
appModel.set
  viewingIncome: $.url.param("income") == "true"
