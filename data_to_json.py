#!/usr/bin/env python
"""
Converts tab separated fields into JSON ready to be eaten by javascript.
"""
import sys
import json
import collections

def factory():
    return collections.defaultdict(factory)

data = collections.defaultdict(factory)
budget = collections.defaultdict(factory)

for line in sys.stdin:
    fields = line.split("\t")
    year = int(fields[0].rstrip()) # $10

    if year == 2012:
        key = "previous_nzd"
    elif year == 2013:
        key = "nzd"
    else:
        continue # We skip years we don't visualise

    dept = fields[1] #$1
    lineitem = fields[2] #$5
    amount = int(fields[3].rstrip().lstrip().replace(",","")) #$9

    # we don't always have Scope data, parse it if we do.
    if len(fields) > 4 and year == 2013:
        scope = fields[4].rstrip() #$13
        budget[dept][lineitem]["scope"] = scope

    # A very few items have more than one line item with the same identifiers,
    # we have to add their costs together.
    if key in budget[dept][lineitem]:
        budget[dept][lineitem][key] += amount * 1000
    else:
        budget[dept][lineitem][key] = amount * 1000

# figure out dept_totals
for dept, lineitems in budget.items():
    data["dept_totals"][dept]["nzd"] = 0
    data["dept_totals"][dept]["previous_nzd"] = 0
    for name, item in lineitems.items():
        if "nzd" in item:
            data["dept_totals"][dept]["nzd"] += item["nzd"]
        if "previous_nzd" in item:
            data["dept_totals"][dept]["previous_nzd"] += item["previous_nzd"]

# figure out grand totals
data["grand_total"]["nzd"] = 0
data["grand_total"]["previous_nzd"] = 0
for dept, lineitems in budget.items():
    for name, item in lineitems.items():
        if "nzd" in item:
            data["grand_total"]["nzd"] += item["nzd"]
        if "previous_nzd" in item:
            data["grand_total"]["previous_nzd"] += item["previous_nzd"]

# We're only plotting items in this year's budget.
# Remove items that were in last years budget, but don't exist this year.
for dept_name, dept in budget.items():
    for item_name, item in dept.items():
        if "nzd" not in item:
            del dept[item_name]

# Convert the budget into a format palatable by HighCharts
series_for_budget = []
for name, dept_expenses in budget.items():
    total = 0
    for item_name, item in dept_expenses.items():
        total += item["nzd"]
    series_for_budget.append([ name, total ])

series_for_budget.sort(key=lambda o: o[1], reverse=True)
data["series_for_budget"] = series_for_budget

# Convert departmental budgets into an array palatable by HighCharts
series_for_dept = {}
for dept_name, dept in budget.items():
    series = []
    for item_name, item in dept.items():
        o = { "name" : item_name, "y" : item["nzd"] }
        if "previous_nzd" in item:
            o["previous_y"] = item["previous_nzd"]
        if "scope" in item:
            o["scope"] = item["scope"]
        series.append(o)
    series.sort(key=lambda o: o["y"],reverse=True)
    series_for_dept[dept_name] = series

data["series_for_dept"] = series_for_dept

print json.dumps(data)
