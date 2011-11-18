#### Helper Methods

# Format a percentage for display, with colors and an arrow pointing up or down.
window.format_percent = (n) ->
  return ""  if n == undefined
  # Round to 2 significant figures - JavaScript doesn't have a
  # builtin function for this.
  num_decimal_points = (if (Math.abs(n) < 10) then 1 else 0)
  s = Math.abs(n).toFixed(num_decimal_points) + "%"
  if n < -0.05
    # Show a decrease in funding in red.
    "(<span style='color:red;'>⇩" + s + "</span>)"
  else if n > 0.05
    # Show a funding increase in green.
    s = "(<span style='color:limegreen;'>⇧" + s + "</span>)"
  else
    s

# Long sentences aren't autowrapped by the highcharts library, and they go over
# the edges of the graph and get clipped. This looks horrible; we have to wrap
# them ourselves. Do this by splitting every fifth word.
window.split_long_sentence = (sentence, joiner) ->
  sentence.replace /([^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+[^\s]+\s+)/g, "$1" + joiner

# A formatter function that gives the tooltip information when hovering over a
# pie slice. Returns some subsetted-HTML for HighCharts to convert into SVG.
window.format_tooltip = ->
  @point.name.replace()
  total = format_big_dollars @y
  splitName = "<b>" + split_long_sentence(@point.name, "<br/><b>")
  proportion_of_total = @y / model.grand_total.nzd
  percentage = "<i>(" + (proportion_of_total * 100).toFixed(2) + "% of total)</i>"
  perperson = "$" + dollars_per_person(@y).toFixed(2) + " per capita."
  scope = if @point.scope? then @point.scope else ""
  splitName + "<br/>" + total + percentage + "<br/>" + perperson + "<br/>" + scope

window.format_big_dollars = (big_dollars) ->
  a_billion = 1000000000
  a_million = 1000000
  if big_dollars > a_billion
   "$" + (big_dollars / a_billion).toFixed(2) + " Billion "
  else
   "$" + (big_dollars / a_million).toFixed(2) + " Million "

# Hardcoded - from the Statistics NZ Population Clock.
window.dollars_per_person = (dollars_per_country) ->
  NZ_POPULATION = 4405193
  dollars_per_country / NZ_POPULATION

# Tests specifically for SVG inline in HTML, not within XHTML
# Nicked from the Modernizr lib.
window.hasSvgSupport = ->
  div = document.createElement('div')
  div.innerHTML = '<svg/>'
  (div.firstChild && div.firstChild.namespaceURI) == "http://www.w3.org/2000/svg"

# The main budget graph title changes 
window.view_budget_pie_title_text = (viewing_income, grand_total) ->
