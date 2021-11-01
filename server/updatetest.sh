#!/bin/bash

# Update the test site.
# $1 is the test site. docroot location
# $2 is the reinstall_modules
cd
./secrets.sh

if [ -z "$1" ]; then
echo "No test site info provided. Exiting."
exit 0
fi
if [ -z "$2" ] ; then
echo "No modules will be reinstalled."
else
reinstall_modules=$2
fi


#if [[ -f $(dirname $1)/composer.lock ]]; then
#	rm $(dirname $1)/composer.lock
#fi
test_docroot=$1
#rm vendor -rf
#  if [[ -f composer.lock ]]; then
#rm composer.lock
#fi
echo "composer install on test"
cd $(dirname $test_docroot)
composer install --no-dev
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
cd
./mainoff.sh $test_docroot
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
cd
./mainoff.sh $test_docroot #this will become prod.
#Now check the site


