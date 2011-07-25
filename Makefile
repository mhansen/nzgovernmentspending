all:
	coffee -c index.coffee

json:
	cat b11-revenue-data.csv    | awk -F '\t' '{ print $$9 "\t" $$1 "\t" $$5 "\t" $$8 }'            | sed 's/"//g' | tail -n +2 | python data_to_json.py | python -mjson.tool > incomes-2011.json
	cat b11-expense-data-v2.csv | awk -F '\t' '{ print $$10 "\t" $$1 "\t" $$5 "\t" $$9 "\t" $$13 }' | sed 's/"//g' | tail -n +2 | python data_to_json.py | python -mjson.tool > expenses-2011.json
