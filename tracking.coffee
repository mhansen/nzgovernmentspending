track_dept_mouseover = (name) ->
  mpq.track "Hovered Over Dept", name: name, mp_note: name
track_subdept_mouseover = (name) ->
  mpq.track "Hovered Over Subdept", name: name, mp_note: name

appModel.bind "dept_mouseover", (_.throttle track_dept_mouseover, 1000)
appModel.bind "subdept_mouseover",(_.throttle track_subdept_mouseover, 1000)

dept_selection_count = 0
appModel.bind "dept_select", (dept_name) ->
  dept_selection_count++
  # ab test: don't log the first dept selection - its done by mouseover
  return if dept_selection_count == 1 and
    abTests.openDeptOnFirstHover.inCohort("openOnHover")

  type = if appModel.get "viewingIncome" then "Income" else "Expense"
  mpq.track "Opened a segment"
    type: type
    dept: dept_name
    deptAndType: "#{type} - #{dept_name}"
    mp_note: "#{type} - #{dept_name}"

$("#receipt_wrapper .receipt").on "scroll",
  _.throttle((-> mpq.track "Scrolled Receipt"), 1000)

appModel.bind "change:viewingIncome", (model, viewingIncome) ->
  if viewingIncome
    mpq.track "View Incomes"
  else
    mpq.track "View Expenses"

$("a#creditslink").on "click", -> mpq.track "Clicked Credits Button"
