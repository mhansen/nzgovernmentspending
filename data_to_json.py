#!/usr/bin/env python
"""
Converts tab separated fields into JSON ready to be eaten by javascript.
"""
import sys
import json
import re
import collections

def factory():
    return collections.defaultdict(factory)

data = collections.defaultdict(factory)

for line in sys.stdin:
    fields = line.split("\t")
    year = int(fields[0].rstrip())

    if year == 2011:
        key = "previous_nzd"
    elif year == 2012:
        key = "nzd"
    else:
        continue # We skip years we don't visualise

    dept = fields[1]
    lineitem = fields[2]
    amount = int(fields[3].rstrip().lstrip().replace(",",""))

    # we don't always have Scope data, parse it if we do.
    if len(fields) > 4 and year == 2012:
        scope = fields[4].rstrip()
        data["budget"][dept][lineitem]["scope"] = scope

    # A very few items have more than one line item with the same identifiers,
    # we have to add their costs together.
    if key in data["budget"][dept][lineitem]:
        data["budget"][dept][lineitem][key] += amount
    else:
        data["budget"][dept][lineitem][key] = amount


    # figure out dept_totals
    for dept, lineitems in data["budget"].items():
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
    for dept, lineitems in data["budget"].items():
        for name, item in lineitems.items():
            if "nzd" in item:
                data["grand_total"]["nzd"] += item["nzd"]
            if "previous_nzd" in item:
                data["grand_total"]["previous_nzd"] += item["previous_nzd"]

print json.dumps(data)
