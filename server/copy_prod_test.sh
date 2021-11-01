#!/bin/bash

SECONDS=0

# Copy the production site to the test site
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

./expandvar.sh $1

#remove test site if it exists
sudo rm $test -rf

#copy live site to test site
sudo cp $prod $test -rf

# Set some permissions right
sudo chown $user:www-data $test -R

#copy in the test settings from backup
sudo cp /home/$user/$test_uri/settings.php $test_docroot/sites/default/settings.php

sudo chown $user:www-data $test_docroot/sites/default/settings.php
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot

#dump the prod database
echo "Going to $prod_docroot to dump database."

if [ ! -d /home/$user/$uri ]; then
  echo "Making directory /home/$user/$uri/"
  mkdir /home/$user/$uri/
fi
if [ ! -d /home/$user/$uri/proddb ]; then
  echo "Making directory /home/$user/$uri/proddb"
  mkdir /home/$user/$uri/proddb
fi

./mainon.sh $prod_docroot
drush sql-dump > /home/$user/$uri/proddb/prod.sql
# Don't take out of maintenance mode until the possible update is run!
# ./mainoff.sh $prod_docroot

#restore the prod db to testdb
# Get the database details from settings.php
dbname=$(sudo grep "'database' =>" /home/$user/$test_uri/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)
echo "Dropping and recreating the database"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < /home/$user/$uri/proddb/prod.sql
# test should not be taken out of maintenace mode until the update is run. So both are now in maintenance mode.
# ./mainoff.sh $test_docroot
