#!/bin/bash
#                            Unmod For Pleasy Library
# Help menu
# Prints user guide
print_help() {
echo \
"Usage: pl unmod [OPTION] ... [SITE] [MODULE]
This script will uninstall a module first using drush then composer.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl unmod cat migrate_plus"
}

args=$(getopt -o h -l help --name "$scriptname" -- "$@")
# echo "$args"

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl unmod --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
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

# start timer
# Timer to show how long it took to run the script
SECONDS=0
# This seems to be a GOD FUNCTION
parse_pl_yml

if [ $1 == "unmod" ]; then
  echo "You need to specify the site and the module in that order"
  print_help
elif [ -z "$2" ]; then
  echo "You have only given one argument. You need to specify the site and the module in that order"
  print_help
else
  sitename_var=$1
  mod=$2
fi

echo "This will install and enable the $mod module for the site $sitename_var using both composer and drush en automatically."
parse_pl_yml
import_site_config $sitename_var

echo "Uninstalling using drush"
drush @$sitename_var pm-uninstall -y $mod

cd $site_path/$sitename_var
echo "Removing module using composer"
composer remove drupal/$mod

# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

