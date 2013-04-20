window.AccountLinksView = Backbone.View.extend
  render: (viewingIncome) ->
    if viewingIncome
      $(@el).html """<a href='/?income=false'>View Expenses</a>
        ● <b>Viewing Incomes</b>"""
    else
      $(@el).html """<b>Viewing Expenses</b>
        ● <a href='/?income=true'>View Incomes</a>"""
