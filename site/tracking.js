let track_dept_mouseover = name => track("Hovered Over Dept", { name, mp_note: name });

let track_subdept_mouseover = function (name) {
  let dept = appModel.get("activeDept");
  return track("Hovered Over Subdept", {
    name,
    dept,
    mp_note: `${dept} # ${name}`
  }
  );
};

appModel.bind("dept_mouseover", (_.throttle(track_dept_mouseover, 1000)));
appModel.bind("subdept_mouseover", (_.throttle(track_subdept_mouseover, 1000)));

let dept_selection_count = 0;
appModel.bind("dept_select", function (dept_name) {
  dept_selection_count++;

  let type = appModel.get("viewingIncome") ? "Income" : "Expense";
  return track("Opened a segment", {
    type,
    dept: dept_name,
    deptAndType: `${type} - ${dept_name}`,
    mp_note: `${type} - ${dept_name}`
  }
  );
});

$("#receipt_wrapper .receipt").on("scroll",
  _.throttle((() => track("Scrolled Receipt")), 1000));

appModel.bind("change:viewingIncome", function (model, viewingIncome) {
  if (viewingIncome) {
    return track("View Incomes");
  } else {
    return track("View Expenses");
  }
});

$("a#creditslink").on("click", () => track("Clicked Credits Button"));
