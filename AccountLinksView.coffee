window.AccountLinksView = Backbone.View.extend
  render: (type) ->
    if type = "Incomes"
      $(@el).html """
<a href='/?income=false'>View Expenses</a> ● <em>Viewing Incomes</em>
"""
    else
      $(@el).html """
<em>Viewing Expenses</em> ● <a href='/?income=true'>View Incomes</a>
"""
