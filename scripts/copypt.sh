#!/bin/bash
#                 copypt (Copy Production site to Test site) For Pleasy Library
#
#  This will copy the production site to the test site.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  09/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
#                                TODO LIST
#
#                             Commenting with model
# NAME OF COMMENT
# Description - Each bar is 80 #, in vim do 80i#esc
#
# scriptname is set in pl.

# Help menu
# Prints user guide
print_help() {
echo \
"Copy the production site to the test site.
Usage: pl copypt [SITE] [OPTION]
  This script is used to copy the production site to the test site. The site
  details are in pl.yml.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl copypt loc"

}

# start timer
# Timer to show how long it took to run the script
SECONDS=0

args=$(getopt -o h -l help --name "$scriptname" -- "$@")

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl addc --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# if no argument passed, default is -- and break loop
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
  -- )
  shift
  break
  ;;
  *)
  "Programming error, this should not show up!"
  exit 1
  ;;
  esac
done
if [ $1 = "copypt" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 0
fi

sitename_var=$1
parse_pl_yml
import_site_config $sitename_var

copy_prod_test

# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))