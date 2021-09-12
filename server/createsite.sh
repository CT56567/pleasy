#!/bin/bash

SECONDS=0

# Update the prod site.
# It is presumed the site files have been uploaded.
# $1 is the site address including docroot.
# $2 is the user



if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
else
  uri=$1
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi


prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Update Production"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Test uri: $test_uri"
echo "User: $user"
echo "Reinstall Modules: $reinstall_modules"

# prod files at prod.tar.gz
# prod db at ~/proddb/prod.sql


#  Presumes the files are transfered.

# Create the settings file.
cd
./fixsitesettings.sh $uri
./fixsitesettings.sh $test_uri


sudo cp ~/ocbackup/teststore/settings.php $test_docroot/sites/default/settings.php

#dbname=$(sudo grep "'database' =>" $1/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)

cd ~/proddb/
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '"$dbpass"';"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql

echo "Site created."

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
