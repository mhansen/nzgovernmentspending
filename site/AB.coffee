mixpanelStorageAdapter =
  onInitialize: (inTest, testName, cohort) ->
    # Called when the user is resolved into a cohort (through chance, or
    # reading a cookie, or reading a hash query param).
    if inTest
      props = {}
      props[testName] = cohort
      mpq.register props
  onEvent: (testName, cohort, eventName) ->
    # There's no need to do anything special on every event
    # after we've registered the super properties.
    return
    
window.abTests =
  openDeptOnFirstHover: new Cohorts.Test
    name: 'openDeptOnFirstHover'
    sample: 1.0 # Sample 100% - all users.
    cohorts:
      openOnHover: {}
      openOnClick: {}
    storageAdapter: mixpanelStorageAdapter
  sizeOfAccountLinks: new Cohorts.Test
    name: 'sizeOfAccountLinks'
    sample: 1.0
    cohorts:
      large:
        onChosen: -> $("#account_links").addClass("large")
      small:
        onChosen: -> $("#account_links").addClass("small")
    storageAdapter: mixpanelStorageAdapter

console.log abTests

if abTests.openDeptOnFirstHover.inCohort("openOnHover")
  openedFirstSubdept = false
  appModel.bind "dept_mouseover", (deptName) ->
    if not openedFirstSubdept
      appModel.trigger "dept_select", deptName
      openedFirstSubdept = true
