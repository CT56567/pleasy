#!/bin/bash

#  Fix the site settings files.
# It is presumed the site files have been uploaded.
# $1 is the site docroot.
# $2 is the profile.

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
else
prod_docroot=$1
fi

user=$USER

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
# if uri is test, then the database will be in prod
  if [ "${uri:0:4}" = "test" ]; then
      prod_uri=${uri:5}
      echo "prod uri: $prod_uri"
  fi


echo "Update Site $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"

# Now store the files
echo "restoring the settings file"
sudo cp  /home/$user/$uri/settings.php "$prod_docroot/sites/default/settings.php"
sudo chown $user:www-data "$prod_docroot/sites/default/settings.php"

echo "drop and restore the database."

dbname=$(sudo grep "'database' =>" "/home/$user/$uri/settings.php"  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)
echo "Drop database"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
echo "Create database"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
echo "restore database"

if [ -f /home/$user/$uri/prod.sql ]; then
  cd /home/$user/$uri
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql
elif [ -f /home/$user/$prod_uri/prod.sql ]; then
  cd /home/$user/$prod_uri/
  mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql
else
  echo "Can't find database for $prod_docroot. Exiting."
  exit 1
  fi

# Fix permissions
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$prod_docroot

cd $prod_docroot
drush cr

echo "Site setup finished."