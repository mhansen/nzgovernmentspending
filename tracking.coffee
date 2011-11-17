track_dept_mouseover = (name) ->
  mpq.track "Hovered Over Dept", name: name, mp_note: name
track_subdept_mouseover = (name) ->
  mpq.track "Hovered Over Subdept", name: name, mp_note: name

events.bind "dept_mouseover", (_.throttle track_dept_mouseover, 1000)
events.bind "subdept_mouseover",(_.throttle track_subdept_mouseover, 1000)

events.bind "dept_select", (dept_name) ->
  # Log which department was clicked on, for statistics.
  $.ajax "/gen204?#{dept_name}"

  type = if viewing_income then "Income" else "Expense"
  mpq.track "Opened a segment"
    type: type
    dept: dept_name
    deptAndType: "#{type} - #{dept_name}"
    mp_note: "#{type} - #{dept_name}"

$("#dept_receipt").on "scroll", _.throttle((-> mpq.track "Scrolled Receipt"), 1000)

events.bind "page_load", (type) -> mpq.track "View #{type}"
