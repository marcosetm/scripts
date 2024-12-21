#!/bin/bash

# decorations
BANNER="
 __       ___        
|  \  /\   |   /\    
|__/ /~~\  |  /~~\                      
 __              __  
|  \ |  |  |\/| |__) 
|__/ \__/  |  | |    
                    
"
# color settings
RED='\033[0;31m'
NC='\033[0m'

# key informaiton
DISTRICT_LOOKUP_CONNECT="mysql -h district-lookup.somegeneratedname.us-west-2.rds.amazonaws.com -D district_lookup" 
YOUR_USERNAME=$(echo $USER)
DB=""
DB_INSTANCE=""
SFTP_USERNAME=""
SFTP_PATH=""
FILE_NAME=""

MAIN() {
	if [[ -z $1 ]]
	then
		echo -e "\necdatadump <district_id>\n"
		exit
	fi

	echo -e "$BANNER"
	echo -e "Hello $YOUR_USERNAME,\n"

	while [ -z $SFTP_PATH ]
	do
		echo -n "Enter sFTP Path to save data dump to (e.g., sis_name/data_dump): "
		read SFTP_PATH
	done

	GET_DISTRICT_INFO $1

	echo -e "\nThe following information will be used to run the script.\n"
	echo -e "> DB: ${RED}$DB${NC}"
	echo -e "> DB_INSTANCE: ${RED}$DB_INSTANCE${NC}"
	echo -e "> SFTP_USERNAME:${RED} $SFTP_USERNAME${NC}"
	echo -e "> SFTP_PATH: ${RED}$SFTP_PATH${NC}"
	echo -e "> FILE_NAME: ${RED}$FILE_NAME${NC}"

	echo -en "\nIs the client information correct? (yes/no) "
	read CONTINUE

	if [[ -z $CONTINUE ]]
	then
		echo -e "\nAborting."
		exit
	elif [[ "$CONTINUE" == "yes" ]]
	then
		RUN_DATA_DUMP $YOUR_USERNAME $DB $DB_INSTANCE
	else
		echo -e "\nAborting."
		exit
	fi

}

GET_DISTRICT_INFO() {
	DATA=$($DISTRICT_LOOKUP_CONNECT -e  'select db_hostname, district_db, db_username FROM district WHERE id = '$1'')

	if [[ -z $DATA ]]
	then
		echo -e "\nNo data returned. Check district ID"
		exit
	fi
	# get data and ommit header
	IFS=" " read -r SPACE SPACE SPACE FULL_DB DB_INSTANCE SFTP_USERNAME <<< $DATA
	# get just the ecdb#
	DB="$(echo $FULL_DB | cut -d. -f1)-read-replica.somegeneratedname.us-west-2.rds.amazonaws.com"
	# set the path and file name
	FILE_NAME="$DB_INSTANCE.sql.gz"
}

RUN_DATA_DUMP() {
	MYSQLDUMP="mysqldump -u $1 -p --host=$2 \
--verbose --quick --force --ssl=true --databases $3 \
| gzip -c > $3.sql.gz "
	MOVE_FILE="sudo mv $DB_INSTANCE.sql.gz /storage/www/sftp/$SFTP_USERNAME/$SFTP_PATH/"
	UPDATE_PERMISSION=" sudo chown $SFTP_USERNAME:sftponly /storage/www/sftp/$SFTP_USERNAME/$SFTP_PATH/$FILE_NAME"
		
	echo -e "${RED}\nRunning mysqldump...${NC}\n"
	eval $MYSQLDUMP

	echo -e "${RED}\nMoving $FILE_NAME to $SFTP_USERNAME/$SFTP_PATH${NC}\n"
	eval $MOVE_FILE

	echo -e "\nUpdating $FILE_NAME permission.\n"
	eval $UPDATE_PERMISSION

	echo -e "\n${RED}Data Dump complete.${NC}
The file is named $FILE_NAME and can be found in the '/$SFTP_PATH' folder."
}

MAIN $1
