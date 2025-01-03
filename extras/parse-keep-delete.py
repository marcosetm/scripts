import pandas as pd

'''
Script to parse output from students not merged
log that is generated by the student-merge script

It will output user-friendly, organized CSV file
'''

records = []
# open and read file line by line
# split the records and keep only what is needed
with open('data.txt', 'r') as f:
	for line in f:
		split_line = line.split("\t")
		records.append({
			"KEEP": split_line[0].replace("Keeper ID(", "").replace(")", "").split("|"), 
			"DELETE": split_line[1].replace("Delete ID(", "").replace(")", "").split("|")
			}
		)

	f.close()

# organize the data in dicts
# eg, ['0524256', 'SMITH', 'JOHN', 'J', '2011-04-08', '5733256796']
data = []
for dict in records:
	temp_dict = {}
	temp_list = []
	for key in dict:
		temp_dict = {
			f"{key} ID": dict[key][0],
			f"{key} First": dict[key][2],
			f"{key} Middle": dict[key][3],
			f"{key} Last": dict[key][1],
			f"{key} DOB": dict[key][4],
			f"{key} SSID": dict[key][5]
		}
		temp_list.append(temp_dict)
	combined = {**temp_list[0], **temp_list[1]}
	data.append(combined)

df = pd.DataFrame(data)
print(df.info())
df.to_csv("students-not-merged.csv", index=False)

print("\nDone!")