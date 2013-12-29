window.AccountLinksView = Backbone.View.extend
  render: (viewingIncome) ->
    if viewingIncome
      $(@el).html "<a href='/?income=false'>Expenses</a> | <b>Incomes</b>"
    else
      $(@el).html "<b>Expenses</b> | <a href='/?income=true'>Incomes</a>"
