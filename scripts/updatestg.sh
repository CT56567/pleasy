#!/bin/bash
################################################################################
#                Update Stage For Pleasy Library
#
#  This will update the stg site with code from the local site.
#  current code
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  15/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################
#                             Commenting with model
#
# NAME OF COMMENT (USE FOR RATHER SIGNIFICANT COMMENTS)
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################

# scriptname is set in pl.

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Update stg or specified site.
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
This will run the updates on stg or specified site.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -t --test               Update the test server not production.

Examples:
pl $scriptname d8 # This will update the d8 stg site with the code in d8.
pl $scriptname d8 stg_t3 # This is update the stg_t3 site with the code in d8."
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hs:dt -l help,step:,debug,test --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl $scriptname --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2; # works
    ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
  verbose="debug"
  shift; ;;
  -t | --test)
  test="yes"
  shift; ;;
  --)
    shift; break; ;;
  *)
    "Programming error, this should not show up!"; ;;
  esac
done

parse_pl_yml

if [ "$1" == "updatestg" ] && [ -z "$2" ]; then
  echo "You must specify a site to work on."
  exit
elif [ -z "$2" ]; then
  from=$1
  sitename_var="stg_$1"
else
  from=$1
  sitename_var=$2
fi

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi


parse_pl_yml

import_site_config $sitename_var

if [[   "$verbose" = "debug" ]]; then
  site_info
fi

prod_reinstall_modules=$reinstall_modules

if [[ "$step" -gt 1 ]] ; then
  echo -e "Starting from step $step"
fi

if [[ "$step" -lt 2 ]] ; then
echo -e "$Pcolor step 1: Copy dev site $from to stg site $sitename_var. $Color_Off"
#  Copy files from local site to prod_site
if [ "$site_path" = "" ] || [ "$sitename_var" = "" ] || [ "$from" == "" ]; then
  #It's really really bad if rsync is run with empty values! It can wipe your home directory!
  echo "One of site_path >$site_path< sitename_var >$sitename_var< or prod_site >$prod_site< is empty aborting."
  exit 1
fi

#drush rsync @$sitename_var @test --no-ansi  -y --exclude-paths=private:.git -- --exclude=.gitignore --delete
# was -rav
# -rzcEPul
  rsync -raz --delete --exclude 'docroot/sites/default/settings.*' \
            --exclude 'docroot/sites/default/services.yml' \
            --exclude 'docroot/sites/default/files/' \
            --exclude 'web/sites/default/settings.*' \
            --exclude 'web/sites/default/services.yml' \
            --exclude 'web/sites/default/files/' \
            --exclude 'html/sites/default/settings.*' \
            --exclude 'html/sites/default/services.yml' \
            --exclude 'html/sites/default/files/' \
            --exclude '.git/' \
            --exclude '.gitignore' \
            --exclude 'private/' \
            --exclude '*/node_modules/' \
            --exclude 'node_modules/' \
            --exclude 'dev/' \
           "$site_path/$from"  "$site_path/$sitename_var/"  # > rsyncerrlog.txt
fi

if [[ "$step" -lt 3 ]] ; then
echo -e "$Pcolor step 2: Runupdates on the stage site $sitename_var. $Color_Off"updateprod.sh
runupdates

fi
#Check changes

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))