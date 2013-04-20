(function() {
  var mixpanelStorageAdapter, openedFirstSubdept;

  mixpanelStorageAdapter = {
    onInitialize: function(inTest, testName, cohort) {
      var props;
      if (inTest) {
        props = {};
        props[testName] = cohort;
        return mpq.register(props);
      }
    },
    onEvent: function(testName, cohort, eventName) {}
  };

  window.abTests = {
    openDeptOnFirstHover: new Cohorts.Test({
      name: 'openDeptOnFirstHover',
      sample: 1.0,
      cohorts: {
        openOnHover: {},
        openOnClick: {}
      },
      storageAdapter: mixpanelStorageAdapter
    }),
    sizeOfAccountLinks: new Cohorts.Test({
      name: 'sizeOfAccountLinks',
      sample: 1.0,
      cohorts: {
        large: {
          onChosen: function() {
            return $("#account_links").addClass("large");
          }
        },
        small: {
          onChosen: function() {
            return $("#account_links").addClass("small");
          }
        }
      },
      storageAdapter: mixpanelStorageAdapter
    })
  };

  console.log(abTests);

  if (abTests.openDeptOnFirstHover.inCohort("openOnHover")) {
    openedFirstSubdept = false;
    appModel.bind("dept_mouseover", function(deptName) {
      if (!openedFirstSubdept) {
        appModel.trigger("dept_select", deptName);
        return openedFirstSubdept = true;
      }
    });
  }

}).call(this);
