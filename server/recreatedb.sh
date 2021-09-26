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

echo "Recreate Database for site $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"

plcred="--defaults-extra-file=/home/$user/mysql.cnf"

#Get database details from settings.php
dbname=$(sudo grep "'database' =>" $prod_docroot/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)
dbuser=$(sudo grep "'username' =>" $prod_docroot/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)
dbpass=$(sudo grep "'password' =>" $prod_docroot/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)

cd /home/$user/$uri/

result=$(
    mysql $plcred -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )
  if [ "$result" = ": 0" ]; then
    echo "Created user $dbuser"
  else
    echo "User $dbuser already exists"
  fi

  result=$(
    mysql $plcred -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )
  if [ "$result" = ": 0" ]; then
    echo "Granted user $dbuser permissions on $dbname"
  else
    result=$(
      mysql $plcred -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $dbname.* TO '$dbuser'@'localhost';" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [ "$result" = ": 0" ]; then
      echo "Granted user $dbuser permissions on $dbname"
    else

      echo "Could not grant user $dbuser permissions on $dbname"
    fi
  fi
}


  result=$(
    mysql $plcred -e "use $dbname;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )
if [ "$result" = ": 0" ]; then
  echo "Database $dbname exists so I will drop it."
      result=$(
        mysql $plcred -e "DROP DATABASE $dbname;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
        echo ": ${PIPESTATUS[0]}"
      )
      if [ "$result" = ": 0" ]; then
        echo "Database $dbname dropped"
      else
        echo "Could not drop database $dbname: exiting"
        exit 1
      fi
fi

result=$(
  mysql $plcred -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
  2>/dev/null | grep -v '+' | cut -d' ' -f2
  echo ": ${PIPESTATUS[0]}"
)
if [ "$result" = ": 0" ]; then
  echo "Created database $dbname using user root"
else
  echo "Could not create database $dbname. Check the mysql root credentials in mysql.cnf, exiting."
  exit 1
fi

if [ -f prod.sql ]; then
mysql $plcred $dbname < prod.sql
else
echo "prod.sql is missing from /home/$user/$uri/  Can't restore the database."
fi

echo "Database restored."