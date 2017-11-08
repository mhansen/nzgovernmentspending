window.AccountLinksView = Backbone.View.extend({
  render(viewingIncome) {
    if (viewingIncome) {
      return $(this.el).html("<a href='/?income=false'>Expenses</a> | <b>Incomes</b>");
    } else {
      return $(this.el).html("<b>Expenses</b> | <a href='/?income=true'>Incomes</a>");
    }
  }
});
