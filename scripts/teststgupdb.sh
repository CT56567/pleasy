#!/bin/bash

#start timer
SECONDS=0
. $script_root/_inc.sh;
parse_pl_yml

if [ $1 == "teststgupdb" ] && [ -z "$2" ]
  then
sn="$sites_stg"
devs="$sites_dev"
prods="$sites_localprod"
elif [ -z "$2" ]
  then
    sn=$1
    devs="$sites_dev"
    prods="$sites_localprod"
   else
    sn=$1
    devs="$sites_dev"
    prods="$sites_localprod"
fi

import_site_config $sn

echo "This presumes stg has all the files copied and will rerun the database update."

# Help menu
print_help() {
cat <<-HELP
This script presumes stg has all the files copied and will rerun the database update.
HELP
exit 0
}

echo "Make sure permissions are correct"
pl fixp $sn

echo -e "\e[34m update database\e[39m"
drush @$sn updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sn fra -y
echo -e "\e[34m import config\e[39m"
drush @$sn cim -y #--source=../cmi
echo -e "\e[34m get out of maintenance mode\e[39m"
drush @$sn sset system.maintenance_mode FALSE
drush cr

# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
