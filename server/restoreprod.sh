#!/bin/bash
##This needs work!!!!!

./secrets.sh
#restoreprod

eval "$(ssh-agent)"
ssh-add /home/$user/.ssh/$prod_key
# $1 is the live site
# presume the live site has the live repo
if [ -z "$2" ]; then
echo "You have not specified a live site and/or a repo. Exiting."
exit 0
fi



#cd $1/..
#git reset --hard

#presume files are corrupt and need to be fully replaced.
cd $prod
git clone $2 "$uri"

# Move settings back into place
sudo cp /home/$user/$uri/settings.php $prod_docroot/sites/default/settings.php

# Fix permissions
cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$prod_docroot &


#restore the prod db 
# Get the database details from settings.php
dbname=$(grep "'database' =>" $prod_docroot/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)

mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < /home/$user/$uri/proddb/prod.sql &
wait

cd $prod_docroot
drush sset system.maintenance_mode FALSE
drush cr

#Now check the site


