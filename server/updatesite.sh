#!/bin/bash

# Not sure what this is suppose to do....???


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

if [ -z "$2" ] ; then
echo "No user given"
exit 0
else
user=$2
fi

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)

echo "Update Site $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"



# Now store the files
echo "storing the settings file"
sudo cp  /home/$user/$uri/settings.php "$prod_docroot/sites/default/settings.php"
sudo chown $user:www-data "$prod_docroot/sites/default/settings.php"

echo "drop and restore the database."
cd ~/$uri
dbname=$(sudo grep "'database' =>" "/home/$user/$uri/settings.php"  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)

mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql


echo "Site setup finished."