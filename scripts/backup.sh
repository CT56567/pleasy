#!/bin/bash

# todo The argument passing could be better. Not sure how to eliminate the need to have -e=

print_help() {
  echo \
    "Backup site and database
Usage: pl backup [OPTION] ... [SOURCE] [MESSAGE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev and an optional message.
You can also optionally specify where the site will be backedup to. This is useful if you are backing up the production
site to a local location, instead of on the production server.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -g --git                Also create a git backup of site.
  -e --endpoint           The backup destination

Examples:
pl backup -h
pl backup dev 'Fixed error'
pl backup tim -e=fred 'First tim backup'

END HELP"
}

# start timer
# Timer to show how long it took to run the script
SECONDS=0

args=$(getopt -o hdge: -l help,debug,git,message: --name "$scriptname" -- "$@")
# echo "$args"

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
  echo "please do 'pl backup --help' for more options"
  exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
site_to=""
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 3 # pass
    ;;
  -d | --debug)
    verbose="debug"
    shift
    ;;
  -g | --git)
    flag_git=1
    shift
    ;;
  -e | --endpoint)
    shift
    site_to=${1:1}
    shift; ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done

# No arguments
# if no argument found exit and display error. User must input directory for
# backup else this script will fail.
if [[ "$1" == "backup" ]] && [[ -z "$2" ]]; then
  echo "No site specified."
elif [[ "$1" == "backup" ]]; then
  sitename_var=$2
elif [[ -z "$2" ]]; then
  sitename_var=$1
else
  sitename_var=$1
  msg="'$*'"
  sitename_var_len=$(echo -n $sitename_var | wc -m)
  msg=${msg:$(($sitename_var_len+2)):-1}
fi
if [[ "$site_to" == "" ]] ; then
  site_to=$sitename_var
  fi



echo -e "\e[34mbackup $sitename_var to $site_to with message $msg\e[39m"

# Read variables from pl.yml
parse_pl_yml
import_site_config $sitename_var

if [ "${sitename_var:0:4}" = "prod" ]; then
  # Backup prod
  backup_prod
else
  # Now backup the site
  backup_site
fi
#This isn't needed (yet?)
# backup_git $msg

# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
