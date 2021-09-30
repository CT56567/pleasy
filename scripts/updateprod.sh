#!/bin/bash
################################################################################
#                Update Prod Production For Pleasy Library
#
#  This will update the production server with code from the local site.
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
"Update Production (or test) server with stg or specified site.
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
This will copy stg or site specified to the production (or test) server and run
the updates on that server. It will also backup the server. It presumes the server
has git which will be used to restore the server if there was a problem.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -t --test               Update the test server not production.

Examples:
pl $scriptname # This will use the site specified in pl.yml by sites: stg:
pl $scriptname d8 # This will update production with the d8 site.
pl $scriptname d8 -t # This will update the test site specified in pl.yml with the d8 site."
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

if [ "$1" == "updateprod" ] && [ -z "$2" ]; then
  sitename_var="$sites_stg"
elif [ -z "$2" ]; then
  sitename_var=$1
fi

if [[ "$test" ]]; then
    echo "This will update production with site $sitename_var"
  else
    echo "This will update the test server with site $sitename_var"
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

prod_reinstall_modules=$reinstall_modules

if [[ "$step" -gt 1 ]] ; then
  echo -e "Starting from step $step"
fi
#echo "Add credentials."
#add_git_credentials
## backup latest on prod
#backup_prod "preupdatebackup"
#
#copy_prod_test

#This presumes a dev2stg and runup has been run on the stage site.
#The files in stage should be ready to move to production/test

# CASE TEST ie update test server, with -t
# 1) prod_site = test
# 2) Don't need to put prod into mainmode or readonly mode
# 3) copy prod to test
# 4) Copy files from local site to test
# 5) Runupdates on the test site.
#   runupdates: runs updatetest.sh with test server details
# runs updb from local
# runs reinstall modules from local
# runs cimx3 from local
# runs mainmod false from local
# runs drush cr from local
# runs fixp script on server from local


# CASE PROD is update prod server.
# 1) prod_site = prod
# 2) put prod into mainmode or readonly mode
# 3) copy prod to test: therefore test should already be in readonly mode.
# 4) Copy files from local site to test site
# 5) Runupdates  on the test site then swap them.. This will do it all.
# runupdates: runs updateprod.sh with test prod and reinstall : does it all!
# runs on test site
# runs composer install
# runs fixp
# runs updb
# runs reinstall mods
# cimx3
# runs drush cr
# runs fixp
# now take out of main/readonly mode.
# swap test with prod
# Put old prod out of main mode

if [[ "$step" -lt 2 ]] ; then
echo -e "$Pcolor step 1: Put into readonlymode and maintenance mode $Color_Off"
# STEP 1
# Always use the test server.
# rsync the files to the server
#if [[ "$test" ]] ; then
#prod_site="$prod_user@$prod_test_uri:$prod_test_docroot" # > rsyncerrlog.txt
prod_site="$prod_alias:$(dirname $prod_test_docroot)"
echo "Prod_site: $prod_site"
#else
#prod_site="$prod_alias:$(dirname $prod_docroot)" # > rsyncerrlog.txt
#fi


# Don't need to put prod into maintenance mode if only running on test.
if [[ ! "$test" ]] ; then
# Check to see if production has the readonly module enabled.
ocmsg "Check to see if production has the readonly module enabled." debug
ssh -t $prod_alias "cd $prod_docroot && drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; }"
readonly_en=$(ssh -t $prod_alias "cd $prod_docroot && drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; }" )

ocmsg "Readonly: >$readonly_en<"
if [ ! "$readonly_en" == "" ]; then
    ssh -t $prod_alias "cd $prod_docroot && drush cset readonlymode.settings enabled 1 -y"
    else
      # otherwise put into maintenance mode
    ssh -t $prod_alias "cd $prod_docroot && drush sset maintenance_mode 1"
fi
ssh -t $prod_alias "cd $prod_docroot && drush cr"
fi

fi
if [[ "$step" -lt 3 ]] ; then
echo -e "$Pcolor step 2: Copy production site to test site. $Color_Off"


#copy production to test.
copy_prod_test
fi
if [[ "$step" -lt 4 ]] ; then
echo -e "$Pcolor step 3: Copy files from local site to prod_site $Color_Off"

#  Copy files from local site to prod_site
if [ "$site_path" = "" ] || [ "$sitename_var" = "" ] || [ "$prod_site" == "" ]; then
  #It's really really bad if rsync is run with empty values! It can wipe your home directory!
  echo "One of site_path >$site_path< sitename_var >$sitename_var< or prod_site >$prod_site< is empty aborting."
  exit 1
fi
ocmsg "Production site $prod_site localsite $site_path/$sitename_var" debug

if [ "$verbose" = "debug" ]; then
  #Double check!
  echo "Do you want to proceed - type y"
  read proc
  if [ "$proc" != "y" ]; then
    exit
  fi
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
            "$site_path/$sitename_var/"  "$prod_site" # > rsyncerrlog.txt

fi
if [[ "$step" -lt 5 ]] ; then
echo -e "$Pcolor step 4: Runupdates on the test/prod site. $Color_Off"

# Runupdates on the test/prod site.
# runup on the server
if [[ "$test" ]] ; then
sitename_var="test_$sitename_var"
else
sitename_var="prod_$sitename_var"
fi

#import_site_config $sitename_var
echo "This will run any updates on the $sitename_var site."
runupdates
fi
#Check changes

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))