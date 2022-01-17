#!/bin/bash
#                       proddown For Pleasy Library
#
#  This script is used to overwrite localprod with the actual external
#  production site.  The choice of localprod is set in pl.yml under sites:
#  localprod: The external site details are also set in pl.yml under prod:
#  Note: once localprod has been locally backedup, then it can just be restored
#  from there if need be.
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
#                                TODO LIST
#   -t --test            Download the test server instead.
#

# scriptname is set in pl.

# Help menu
# Prints user guide
print_help() {
echo \
"Overwrite a specified local site with production
Usage: pl proddown [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: If the local site will be deleted if it already exists. Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function


Examples:
pl proddown loc
pl proddown loc -s=2
pl proddown
END HELP"

}



# start timer
# Timer to show how long it took to run the script
SECONDS=0

# step is defined for script debug purposesstep=${step:-1}

args=$(getopt -o hs:d -l help,step:,debug --name "$scriptname" -- "$@")

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl proddown --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2 # works
    ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
#  -t | --test)
#    test="y"
#    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

parse_pl_yml
sitename_var=$1
if [ $1 = "proddown" ] && [ -z "$2" ]; then
  echo "No site specified, exiting"
fi

import_site_config $sitename_var

# Make sure @prod is setup.
update_all_configs

echo "step $step"

echo "Importing $sitename_var production site into stg_$sitename_var"

if [[ "$step" -gt 1 ]] ; then
  echo "Starting from step $step"
fi

if [[ "$step" -lt 2 ]] ; then
  echo -e "$Cyan step 1: backup production $Color_Off"

  to=$sitename_var
  backup_prod
  # sql file: $Namesql
  # all files: $folderpath/sitebackups/prod/$Name.tar.gz
  sitename_var=$to
fi

if [[ "$step" -lt 3 ]] ; then
  echo -e "$Cyan step 2: restore production to $sitename_var $Color_Off"
  if [[ "$verbose"=="debug" ]]; then
  pl restore prod "stg_$sitename_var" -yfd
  else
  pl restore prod "stg_$sitename_var" -yf
  fi
fi
#

# Make sure url is setup and open it!
#pl sudoeuri localprod
echo -e "$Cyan Opening stg_$sitename_var $Color_Off"
pl open "stg_$sitename_var"
# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
