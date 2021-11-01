#!/bin/bash
# Turn maintenance or readonly mode off
# $1 is the prod site. docroot location ie prod_docroot

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

prod_docroot=$1
cd $prod_docroot
readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; } )
if [ ! "$readonly_en" == "" ]; then
  #take out of readonly mode.
drush cset readonlymode.settings enabled 0   -y
fi

# Make sure its not in maintenance mode
drush sset maintenance_mode 0
drush cr
