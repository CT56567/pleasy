#!/bin/bash

print_help() {
echo \
"Restore a particular site's  database.
You just need to state the sitename, eg d9.
You can alternatively restore the site into a different site which is the second argument.

Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl $scriptname d9 # This will restore the db on the d8 site."
}

# start timer
# Timer to show how long it took to run the script
SECONDS=0

args=$(getopt -o hd -l help,debug --name "$scriptname" -- "$@")
# echo "$args"

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl $scriptname --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2; # works
    ;;
  -d | --debug)
  verbose="debug"
  shift; ;;
  --)
    shift; break; ;;
  *)
    "Programming error, this should not show up!"; ;;
  esac
done

if [ $1 == "$scriptname" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1;
fi
if [ -z "$2" ]
  then
    sitename_var=$1
    bk=$1
    echo -e "\e[34mrestore $1 \e[39m"
   else
    bk=$1
    sitename_var=$2
    echo -e "\e[34mrestoring $1 to $2 \e[39m"
fi

# Check number of arguments
# If no arguments given, prompt user for arguments
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

parse_pl_yml
import_site_config $sitename_var

# Prompt to choose which database to backup, 1 will be the latest.
prompt="Please select a backup:"
if [ "${bk: -4}" = "prod" ]; then
      siteto_var_len=$(echo -n $bk | wc -m)
      sitename_pre=${bk:0:$(($siteto_var_len - 5))}
  cd "$folderpath/sitebackups/$sitename_pre/prod/"
  else
  cd "$folderpath/sitebackups/$bk"
fi

options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )

PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $REPLY which is file ${opt:2}"
        Name=${opt:2}
        break

    else
        echo "Invalid option. Try another one."
    fi
done

#restore db
db_defaults
restore_db


# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))