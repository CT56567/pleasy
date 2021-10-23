#!/bin/bash

SECONDS=0

# Update the prod site.
# $1 is the prod site. docroot location
# $2 is the user
# $3 modules to be reinstalled. Put the modules in quotation marks.
# Put production into readonly mode

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi
if [ -z "$3" ] ; then
echo "No modules will be reinstalled."
else
reinstall_modules=$3
fi

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Update Production"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test uri: $test_uri"
echo "User: $user"
echo "Reinstall Modules: $reinstall_modules"

#Check if variables are empty
if [[ "$test" = "" ]]; then
  echo "test site variable is empty. Aborting."
  exit 1
fi
if [[ "$test_docroot" = "" ]]; then
  echo "test site docroot variable is empty. Aborting."
  exit 1
fi
if [[ "$prod" = "" ]]; then
  echo "prod site variable is empty. Aborting."
  exit 1
fi
if [[ "$prod_docroot" = "" ]]; then
  echo "prod site docroot variable is empty. Aborting."
  exit 1
fi
if [[ "$uri" = "" ]]; then
  echo "uri variable is empty. Aborting."
  exit 1
fi
if [[ "$user" = "" ]]; then
  echo "user variable is empty. Aborting."
  exit 1
fi


### These next couple of steps are done from the local site since they need to be done before rsync which is local.

#echo "Put production into readonly mode."
#cd $2
#readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | grep "readonlymode")
#if [ ! "$readonly_en" == "" ]; then
#drush vset site_readonly 1 
#fi

#copy production to test
#echo "Copy prod to test"
#cd
#./copy_prod_test.sh $test_docroot $prod_docroot

#now rsync the new files!!


#update test
echo "Run the updates on test"
#if [[ -f $test/composer.lock ]]; then
#echo "remove composer.lock in test"
#	rm $(dirname $1)/composer.lock
#fi
cd $test
#rm vendor -rf
echo "composer install on test"
composer install --no-dev
# Run the updates
# to $user:www-data so git can deal with them.
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot

cd $test_docroot
echo "update drupal db in test"
drush updb -y
echo "reinstall test modules: $reinstall_modules"
drush pm-uninstall $reinstall_modules -y
echo "test import config"
drush cim -y
result="$?"
if [ "$result" -ne 0 ]; then
echo "The Drush import failed. Aborting."
exit 1
fi
drush cim -y
drush cim -y
drush en $reinstall_modules -y
drush cr

# set site permissions
echo "set site permissions on test."
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot

# put test out of read only mode or maintenance mode
echo "Put test out of readonly mode or maintenance mode."
cd $1
readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; })
if [ ! "$readonly_en" == "" ]; then
echo "Moving out of readonly mode."
drush cset readonlymode.settings enabled 0 -y
else
echo "Moving out of maintenance mode"
drush sset system.maintenance_mode FALSE
fi
drush cr

# swap the sites
echo "Swap test and prod sites."
cd /var/www
echo "Move prod to old"
sudo mv $uri "old.$uri"
echo "Move test to prod."
sudo mv $test_uri $uri
echo "Move old to test."
sudo mv "old.$uri" $test_uri
echo "Move settings from teststore to back/settings"
sudo mv /home/$user/$test_uri/settings.php /home/$user/settings.php
echo "Move settings from prodstore to teststore."
sudo mv /home/$user/$uri/settings.php /home/$user/$test_uri/settings.php
echo "Move back/settings to prodstore."
sudo mv /home/$user/settings.php /home/$user/$uri/settings.php

# put the old prod out of read only mode or maintenance mode
echo "Put old prod {test.opencat.org} out of readonly mode or maintenance mode."
cd $test_docroot
readonly_en=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; })
if [ ! "$readonly_en" == "" ]; then
echo "Moving out of readonly mode."
drush cset readonlymode.settings enabled 0 -y
else
echo "Moving out of maintenance mode"
drush sset system.maintenance_mode FALSE
fi
drush cr

echo "Production update completed." 

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
