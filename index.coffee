# Main client-side logic for the wheresmytaxes site.
#
# Compile with coffeescript: `coffee -c index.coffee`

if document.location.hostname == "localhost"
  mpq.track = -> console.log arguments

window.events = new Backbone.Model

govtPieView = new GovtPieView el: "#budget_container"
deptPieView = new DeptPieView el: "#dept_graph"
deptReceiptView = new DeptReceiptView el: "#receipt_wrapper"

events.bind "page_load", (type, filename) ->
  # Fetch the file, save the model data, and plot the budget.
  $.getJSON filename, (fetched_data) ->
    window.model = fetched_data
    govtPieView.render model.series_for_budget, viewing_income, model.grand_total.nzd

window.model = {}
$ ->
  $("a#creditslink").fancybox()
  # Are we looking at income or expenses? Fetch the right file, and link to the
  # other page.
  window.viewing_income = $.url.param("income") == "true"

  # IE <9 and android <3.0 don't support SVG, so we can't render the charts. :(
  if not hasSvgSupport()
    alert "Sorry, your browser doesn't support inline SVG.\n" +
          "We can't show render the graphs without it."
    return

  if viewing_income
    events.trigger "page_load", "Incomes", "incomes-2011.json"
  else
    events.trigger "page_load", "Expenses", "expenses-2011.json"

events.bind "page_load", (type) ->
  if type = "Incomes"
    $("#incomes_or_expenses").html "<a href='/?income=false'>View Expenses</a>" +
                                   " ● <em>Viewing Incomes</em>"
  else
    $("#incomes_or_expenses").html "<em>Viewing Expenses</em>" +
                                   " ● <a href='/?income=true'>View Incomes</a>"

events.bind "dept_select", (dept_name) ->
  d = model.dept_totals[dept_name]
  dept_percent_change = 100 * ((d.nzd - d.previous_nzd) / d.previous_nzd)
  deptPieView.render dept_name, model.series_for_dept[dept_name], dept_percent_change
  deptReceiptView.render model.series_for_dept[dept_name]
