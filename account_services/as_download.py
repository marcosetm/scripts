import csv
import requests

'''
This script will download all accounts from AS for a specific client
'''

# constants 
BASE_URL = "https://accounts.comapanyurl.com/api/v2/accounts"
HEADERS = {
	"Content-Type": "application/json",
	"X-IED-SERVICE-TOKEN": "super-screte-token",
	"X-IED-CLIENT-ID": "specific-client-secret-id"
}

param_url = f"{BASE_URL}?type=staff&size=100"

r = requests.get(param_url, headers=HEADERS)

if r.status_code == 200:
	print("Loading AS data")

	json_r = r.json()
	num_pages = json_r["metadata"]["paging"]["pages"]

	print(f"Total Pages: {num_pages}")
	
	all_accts = []

	for page in range(1, num_pages + 1):
		url = f"{param_url}&page={page}"
		print(f"Getting data from: {url}")

		data = requests.get(url, headers=HEADERS)
		json_data = data.json()
		items = json_data["items"]

		for item in items:
			all_accts.append(item["account"])
	
	datafile = open("as_data_file.csv", "w")

	csv_writer = csv.writer(datafile)

	write_header = True 

	for acct in all_accts:
		if write_header:
			header = acct.keys()
			csv_writer.writerow(header)
			write_header = False
		
		csv_writer.writerow(acct.values())
	
	datafile.close()

else:
	print("no bueno")


