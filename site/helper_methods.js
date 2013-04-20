
  window.format_percent = function(n) {
    var num_decimal_points, s;
    if (n === void 0) return "";
    num_decimal_points = (Math.abs(n) < 10 ? 1 : 0);
    s = Math.abs(n).toFixed(num_decimal_points) + "%";
    if (n < -0.05) {
      return "(<span style='color:red;'>⇩" + s + "</span>)";
    } else if (n > 0.05) {
      return "(<span style='color:limegreen;'>⇧" + s + "</span>)";
    } else {
      return s;
    }
  };

  window.split_long_sentence = function(sentence, joiner) {
    return sentence.replace(/([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner);
  };

  window.format_tooltip = function() {
    var percentage, perperson, proportion_of_total, scope, splitName, total;
    this.point.name.replace();
    total = format_big_dollars(this.y);
    splitName = "<b>" + split_long_sentence(this.point.name, "<br/><b>");
    proportion_of_total = this.y / model.grand_total.nzd;
    percentage = "<i>(" + (proportion_of_total * 100).toFixed(2) + "% of total)</i>";
    perperson = "$" + dollars_per_person(this.y).toFixed(2) + " per capita.";
    scope = this.point.scope != null ? this.point.scope : "";
    return splitName + "<br/>" + total + percentage + "<br/>" + perperson + "<br/>" + scope;
  };

  window.format_big_dollars = function(big_dollars) {
    var a_billion, a_million;
    a_billion = 1000000000;
    a_million = 1000000;
    if (big_dollars > a_billion) {
      return "$" + (big_dollars / a_billion).toFixed(2) + " Billion ";
    } else {
      return "$" + (big_dollars / a_million).toFixed(2) + " Million ";
    }
  };

  window.dollars_per_person = function(dollars_per_country) {
    var NZ_POPULATION;
    NZ_POPULATION = 4405193;
    return dollars_per_country / NZ_POPULATION;
  };

  window.hasSvgSupport = function() {
    var div;
    div = document.createElement('div');
    div.innerHTML = '<svg/>';
    return (div.firstChild && div.firstChild.namespaceURI) === "http://www.w3.org/2000/svg";
  };
