
window.AccountLinksView = Backbone.View.extend({
  render: function(viewingIncome) {
    if (viewingIncome) {
      return $(this.el).html("<a href='/?income=false'>View Expenses</a>\n● <b>Viewing Incomes</b>");
    } else {
      return $(this.el).html("<b>Viewing Expenses</b>\n● <a href='/?income=true'>View Incomes</a>");
    }
  }
});
