track_dept_mouseover = (name) ->
  track "Hovered Over Dept", name: name, mp_note: name

track_subdept_mouseover = (name) ->
  dept = appModel.get "activeDept"
  track "Hovered Over Subdept",
    name: name
    dept: dept
    mp_note: "#{dept} # #{name}"

appModel.bind "dept_mouseover", (_.throttle track_dept_mouseover, 1000)
appModel.bind "subdept_mouseover",(_.throttle track_subdept_mouseover, 1000)

dept_selection_count = 0
appModel.bind "dept_select", (dept_name) ->
  dept_selection_count++

  type = if appModel.get "viewingIncome" then "Income" else "Expense"
  track "Opened a segment",
    type: type
    dept: dept_name
    deptAndType: "#{type} - #{dept_name}"
    mp_note: "#{type} - #{dept_name}"

$("#receipt_wrapper .receipt").on "scroll",
  _.throttle((-> track "Scrolled Receipt"), 1000)

appModel.bind "change:viewingIncome", (model, viewingIncome) ->
  if viewingIncome
    track "View Incomes"
  else
    track "View Expenses"

$("a#creditslink").on "click", -> track "Clicked Credits Button"
