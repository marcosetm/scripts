import csv
import requests

'''
This script will download specific accounts from 
specific client based on the input file
'''

# constants 
BASE_URL = "https://accounts.comapanyurl.com/api/v2/accounts"
HEADERS = {
	"Content-Type": "application/json",
	"X-IED-SERVICE-TOKEN": "super-screte-token",
	"X-IED-CLIENT-ID": "specific-client-secret-id"
}

# check status
r = requests.get(f"{BASE_URL}", headers=HEADERS)

if r.status_code == 200:
	print("Reading file\n")
	emails = []
	#input file
	with open("someclient_emails.txt", "r") as f:
		lines = f.readlines()
		for line in lines:
			emails.append(line.rstrip("\n"))
			
		
		print(f"{len(emails)} emails loaded.\n")
	f.close()

	accounts = []

	print("\nGETTING ACCOUNTS FROM AS\n")

	for email in emails:
		url = f"{BASE_URL}?email={email}"
		data = requests.get(url, headers=HEADERS)
		json_data = data.json()
		count = json_data["metadata"]["count"]

		if count == 1 and data.status_code == 200:
			accounts.append(json_data["items"][0]["account"])
		else:
			print(f"Error: {data.status_code}")


	print(f"Downloaded {len(accounts)} accounts from AS.\n")

	print("Loading data into file.\n")
	file = open("accounts.csv", "w")

	csv_writer = csv.writer(file)

	write_header = True 

	num_written = 0

	for account in accounts:
		if write_header:
			header = account.keys()
			csv_writer.writerow(header)
			write_header = False
		
		csv_writer.writerow(account.values())
		num_written += 1
	
	file.close()

	print(f"Wrote {num_written} accounts to file. Check {file.name}")

else:
	print(f"No Bueno! Response returned: {r.status_code}")


