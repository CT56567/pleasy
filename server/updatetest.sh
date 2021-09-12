#!/bin/bash

# Update the test site.
# $1 is the test site. docroot location
# $2 is the user

if [ -z "$1" ]; then
echo "No test site info provided. Exiting."
exit 0
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi

#if [[ -f $(dirname $1)/composer.lock ]]; then
#	rm $(dirname $1)/composer.lock
#fi
cd $(dirname $1)
#rm vendor -rf
#  if [[ -f composer.lock ]]; then
#rm composer.lock
#fi
composer install --no-dev
# Run the updates
# to $user:www-data so git can deal with them.
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$1

#cd $1
#drush updb -y
#drush sset system.maintenance_mode FALSE
#drush cim -y
#drush cim -y
#drush cim -y
#drush sset system.maintenance_mode FALSE
#drush cr

#Now check the site


