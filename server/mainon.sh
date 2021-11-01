#!/bin/bash
# Turn maintenance or readonly mode on
# $1 is the prod site. docroot location ie prod_docroot

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

prod_docroot=$1
cd $prod_docroot

# If not in maintenance mode, then put it in maintenance mode
mainm=$(drush sget maintenance_mode)
# Check to see if production has the readonly module enabled.
echo "Check to see if production has the readonly module enabled."
readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; } )

roc="0"
if [ ! "$readonly_en" == "" ]; then
	roc=$(drush cget readonlymode.settings enabled)
	rom=${roc: -1}
fi


if [[ "$mainm" == "false" ]] && [[ "$rom" == "0" ]] ; then
echo "Readonly: >$readonly_en<"
if [ ! "$readonly_en" == "" ]; then
drush cset readonlymode.settings enabled 1 -y
else
      # otherwise put into maintenance mode
    drush sset maintenance_mode 1
fi
drush cr
else
alreadyon="y"
echo "Already in maintenance or readonly mode"
fi