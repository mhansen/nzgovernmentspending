//### Helper Methods

// Format a percentage for display, with colors and an arrow pointing up or down.
window.format_percent = function (n) {
  if (n === undefined) { return ""; }
  // Round to 2 significant figures - JavaScript doesn't have a
  // builtin function for this.
  let num_decimal_points = ((Math.abs(n) < 10) ? 1 : 0);
  let s = Math.abs(n).toFixed(num_decimal_points) + "%";
  if (n < -0.05) {
    // Show a significant funding decrease in red.
    return `(<span style='color:red;'>⇩${s}</span>)`;
  } else if (n > 0.05) {
    // Show a significant funding increase in green.
    return `(<span style='color:limegreen;'>⇧${s}</span>)`;
  } else {
    return s;
  }
};

// Long sentences aren't autowrapped by the highcharts library, and they go over
// the edges of the graph and get clipped. This looks horrible; we have to wrap
// them ourselves. Do this by splitting every fifth word.
window.split_long_sentence = (sentence, joiner) => sentence.replace(/([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, `$1${joiner}`);

// A formatter function that gives the tooltip information when hovering over a
// pie slice. Returns some subsetted-HTML for HighCharts to convert into SVG.
window.format_tooltip = function () {
  this.point.name.replace();
  let total = format_big_dollars(this.y);
  let splitName = `<b>${split_long_sentence(this.point.name, "<br/><b>")}`;
  let proportion_of_total = this.y / model.grand_total.nzd;
  let percentage = `<i>(${(proportion_of_total * 100).toFixed(2)}% of total)</i>`;
  let perperson = `$${dollars_per_person(this.y).toFixed(2)} per capita.`;
  let scope = (this.point.scope != null) ? this.point.scope : "";
  return splitName + "<br/>" + total + percentage + "<br/>" + perperson + "<br/>" + scope;
};

window.format_big_dollars = function (big_dollars) {
  let a_billion = 1000000000;
  let a_million = 1000000;
  if (big_dollars > a_billion) {
    return `$${(big_dollars / a_billion).toFixed(2)} Billion `;
  } else {
    return `$${(big_dollars / a_million).toFixed(2)} Million `;
  }
};

// Hardcoded - from the Statistics NZ Population Clock.
window.dollars_per_person = function (dollars_per_country) {
  const NZ_POPULATION = 4405193;
  return dollars_per_country / NZ_POPULATION;
};
