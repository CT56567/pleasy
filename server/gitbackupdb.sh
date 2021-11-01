#!/bin/bash
Color_Off='\033[0m' # Text Reset

# Regular Colors
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
./secrets.sh

#creates a DB backup of opencat.
echo -e "$Purple"
if [ -z $1 ] ; then
    echo "You have not specified a site"
    exit 1
fi
if [[ ! -d $1 ]] ; then
echo "The site does not exist"
exit 1
fi
if [ -z $2 ] ; then
    echo "You have not specified a message"
    exit 1
fi
./expandvar.sh $1
cd $1
echo "Now in $1"
#Name="C-"$(date +"%Y-%m-%d")".sql"
# Maintenance mode is controlled remotely so this script is more useful.
# todo include readonly mode here.
drush sset system.maintenance_mode TRUE
drush cr
drush sql-dump > /home/$user/$uri/proddb/prod.sql
drush sset system.maintenance_mode FALSE

cd /home/$user/$uri/proddb/
eval "$(ssh-agent)"
ssh-add /home/$user/.ssh/$prod_key
git add .
git commit -m "$2"
git push
echo -e "Database pushed to git $Color_Off"
