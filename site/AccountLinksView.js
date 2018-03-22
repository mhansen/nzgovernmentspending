window.AccountLinksView = Backbone.View.extend({
  render(viewingIncome) {
    if (viewingIncome) {
      return this.el.innerHTML = "<a href='/?income=false'>Expenses</a> | <b>Incomes</b>";
    } else {
      return this.el.innerHTML = "<b>Expenses</b> | <a href='/?income=true'>Incomes</a>";
    }
  }
});
