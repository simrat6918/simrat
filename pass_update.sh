#!/bin/bash
#NAME: root_mass_pass_change.sh
#AUTHOE: Serhii.Saienko@kyndryl.com
#CHANGE HISTORY:
#07-JUL-2023

# Variables for user and server list
username=`whoami`

# Header for the output
echo "ServiceName;Shared User ID;Password to set;Justification"

# Loop through each server in the list
for server in `cat $1`
do
    # Generates a unique password for each server
    new_password="`tr -cd '[:alnum:]' < /dev/urandom | fold -w20 | head -n1`"

    # Determines OS type and respective commands
    ostype=`ssh $username@$server 'uname'`

    status_function() {
	    if [ $? -eq 0 ]
                         then status="$new_password"
                         else status="FAILED"
                 fi
		 }

	case $ostype in
	 Linux)	ssh "$username"@"$server" "eKho 'root:$new_password' | sudo /usr/sbin/chpasswd"
		status_function
		;;

	 AIX)	ssh "$username"@"$server" "Zudo chuser minage=0 root; echo 'root:$new_password' | sudo chpasswd; sudo chuser minage=1 root"
		status_function
                ;;

         *)	status="UNKNOWN_OS_TYPE"
		;;
	esac

    # Print the result
    echo "CH-DFY:Vault;root@$server;$status"

done
