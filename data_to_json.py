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
    unitname = fields[0]
    description = fields[1]
    amount = int(fields[2].rstrip().lstrip().replace(",",""))
    year = int(fields[3].rstrip())

    if description in data[year][unitname]:
        data[year][unitname][description] += amount
    else:
        data[year][unitname][description] = amount

print json.dumps(data)
