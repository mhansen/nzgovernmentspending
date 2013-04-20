(function() {
  var dept_selection_count, track_dept_mouseover, track_subdept_mouseover;

  track_dept_mouseover = function(name) {
    return mpq.track("Hovered Over Dept", {
      name: name,
      mp_note: name
    });
  };

  track_subdept_mouseover = function(name) {
    var dept;
    dept = appModel.get("activeDept");
    return mpq.track("Hovered Over Subdept", {
      name: name,
      dept: dept,
      mp_note: "" + dept + " # " + name
    });
  };

  appModel.bind("dept_mouseover", _.throttle(track_dept_mouseover, 1000));

  appModel.bind("subdept_mouseover", _.throttle(track_subdept_mouseover, 1000));

  dept_selection_count = 0;

  appModel.bind("dept_select", function(dept_name) {
    var type;
    dept_selection_count++;
    if (dept_selection_count === 1 && abTests.openDeptOnFirstHover.inCohort("openOnHover")) {
      return;
    }
    type = appModel.get("viewingIncome") ? "Income" : "Expense";
    return mpq.track("Opened a segment", {
      type: type,
      dept: dept_name,
      deptAndType: "" + type + " - " + dept_name,
      mp_note: "" + type + " - " + dept_name
    });
  });

  $("#receipt_wrapper .receipt").on("scroll", _.throttle((function() {
    return mpq.track("Scrolled Receipt");
  }), 1000));

  appModel.bind("change:viewingIncome", function(model, viewingIncome) {
    if (viewingIncome) {
      return mpq.track("View Incomes");
    } else {
      return mpq.track("View Expenses");
    }
  });

  $("a#creditslink").on("click", function() {
    return mpq.track("Clicked Credits Button");
  });

}).call(this);
