#!/bin/bash

# oc includes
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

# Modified from: https://gist.github.com/aamnah/f03c266d715ed479eb46
#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

import_site_config () {
# setup basic defaults
sn=$1

# First load the defaults
rp="recipes_default_source" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; else project=""; fi
rp="recipes_default_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; else dev=""; fi
rp="recipes_default_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; else webroot=""; fi
rp="recipes_default_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; else sitename=""; fi
rp="recipes_default_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ; else auto=""; fi
rp="recipes_default_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; else apache=""; fi
rp="recipes_default_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; else dbuser=""; fi
rp="recipes_default_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; else profile=""; fi
rp="recipes_default_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ; else db=""; fi
rp="recipes_default_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; else dbpass=""; fi
rp="recipes_default_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; else uri="$folder.$sn"; fi
rp="recipes_default_install_method" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_method=${!rp} ; else install_method=""; fi
rp="recipes_default_git_upstream" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then git_upstream=${!rp} ; else git_upstream=""; fi
rp="recipes_default_theme" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme=${!rp} ; else theme=""; fi
rp="recipes_default_theme_admin" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme_admin=${!rp} ; else theme_admin=""; fi
rp="recipes_default_install_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_modules=${!rp} ; else install_modules=""; fi
rp="recipes_default_dev_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev_modules=${!rp} ; else dev_modules=""; fi
rp="recipes_default_lando" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then lando=${!rp} ; else lando=""; fi

# Collect the details from pl.yml if they exist otherwise make blank
# This first one is to override the defaults, ie default= n so if a site wants to leave it blank, but the default has a value, it will be left blank.
# Though some values need to have a value and so if blank will get their values from the default recipe.
rb="recipes_${sn}_default"
rp="recipes_${sn}_source" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; fi
rp="recipes_${sn}_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; fi
rp="recipes_${sn}_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ;  fi
rp="recipes_${sn}_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ;  fi
rp="recipes_${sn}_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ;  fi
rp="recipes_${sn}_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ;  fi
rp="recipes_${sn}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; elif [ "${!rb}" == "n" ] ; then dbuser=""; fi
rp="recipes_${sn}_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; fi
rp="recipes_${sn}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ; elif [ "${!rb}" == "n" ] ; then db=""; fi
rp="recipes_${sn}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; elif [ "${!rb}" == "n" ] ; then dbpass=""; fi
rp="recipes_${sn}_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ;  fi
rp="recipes_${sn}_install_method" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_method=${!rp} ; fi
rp="recipes_${sn}_git_upstream" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then git_upstream=${!rp} ; elif [ "${!rb}" == "n" ] ; then git_upstream=""; fi
rp="recipes_${sn}_theme" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme=${!rp} ; elif [ "${!rb}" == "n" ] ; then theme=""; fi
rp="recipes_${sn}_theme_admin" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then theme_admin=${!rp} ; elif [ "${!rb}" == "n" ] ; then theme_admin=""; fi
rp="recipes_${sn}_install_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then install_modules=${!rp} ; elif [ "${!rb}" == "n" ] ; then install_modules="";  fi
rp="recipes_${sn}_dev_modules" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev_modules=${!rp} ; elif [ "${!rb}" == "n" ] ; then dev_modules=""; fi
rp="recipes_${sn}_lando" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then lando=${!rp} ; fi

if [ "$db" = "" ] ; then db="$sn$folder" ; fi
if [ "$dbuser" = "" ] ; then dbuser=$db ; fi
if [ "$dbpass" = "" ] ; then dbpass=$dbuser ;fi

if [[ "$sitename" == "" ]] ; then sitename="$sn" ; fi

if [ "$lando" = "y" ]
then
folder=$(basename $(dirname $script_root))
private="/home/$user/$folder/$sn/private"
site_path="/home/$user/$folder"
else
private="$www_path/$sn/private"
site_path="$www_path"
fi

}

parse_pl_yml () {
# Import yaml
# presumes $script_root is set
# $userhome
update_config="n"

. $script_root/scripts/parse_yaml.sh "pl.yml" $script_root
# Project is no longer set in pl.yml. It is collected from the context.
project=$folder
if [ $update_config == "y" ]
then
  if [ ! -z "$no_config_update" ]
  then
    update_all_configs
  else
    if [ "$no_config_update" != "true" ]
then
update_all_configs
fi
fi
fi

}

update_all_configs () {
echo "update configs"
# Update all database credentials in case the user changed any.
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

# Store the site name to restore it later
storesn=$sn

# Setup drupal console if it is installed.
drupalconsole="y"

# Create drupal console file
if [ ! -d "$user_home/.console" ]
then
ocmsg "Drupal console is not installed."
drupalconsole="n"
else
if [ ! -d $user_home/.console/sites ]
then
mkdir $user_home/.console/sites
fi
fi
# Clear current file
ocmsg "$user_home/.console/sites/$folder.yml"
echo "" > "$user_home/.console/sites/$folder.yml"

#Collect the drush location: messy but it works!
# This command might list some warnings. It is a bug with drush: https://github.com/drush-ops/drush/issues/3226
ocmsg $folderpath/drush.tmp
if [[ $folderpath/drush.tmp =~ (@dev) ]] ;
then
drush @dev status > "$folderpath/drush.tmp"
else
drush status > "$folderpath/drush.tmp"
fi

dline=$(awk 'match($0,v){print NR; exit}' v="Drush script" "$folderpath/drush.tmp")
dlinec=$(sed "${dline}q;d" "$folderpath/drush.tmp")
dlined="/$(echo "${dlinec#*/}")"
drushloc=${dlined::-11}
rm "$folderpath/drush.tmp"

if [ -f $user_home/.drush/$folder.aliases.drushrc.php ]
then
rm  $user_home/.drush/$folder.aliases.drushrc.php
fi

cat > $user_home/.drush/$folder.aliases.drushrc.php <<EOL
<?php
/**
 * This file has been created by $site_folder/scripts/_inc.sh
 *
 */
 \$aliases['prod'] = array (
  'uri' => '$prod_uri',
  'root' => '$prod_docroot',
  'remote-user' => '$prod_user',
  'remote-host' => '$prod_uri',
);
EOL

# Delete old credentials folder if it exists
if [ -d $folderpath/credentials ] ; then rm $folderpath/credentials -rf ; fi
mkdir $folderpath/credentials

# Now go through each site and create settings for each site.
Field_Separator=$IFS
# set comma as internal field separator for the string list
IFS=,
for site in $recipes;
do
  # Database defaults
  rp="recipes_${site}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdb=${!rp}; else sdb="$site$folder"; fi
  rp="recipes_${site}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbuser=${!rp}; else sdbuser=$sdb; fi
  rp="recipes_${site}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbpass=${!rp}; else sdbpass=$sdbuser; fi

  cat > $(dirname $script_root)/credentials/$site.mysql <<EOL
[client]
user = $sdbuser
password = $sdbpass
host = localhost
EOL

  #Now go through and create a Drush Alias for each site
  import_site_config $site

  cat >> $user_home/.drush/$folder.aliases.drushrc.php <<EOL
\$aliases['$site'] = array (
  'root' => '$site_path/$site/$webroot',
  'uri' => 'http://$folder.$site',
  'path-aliases' =>
  array (
    '%drush' => '$drushloc',
    '%site' => 'sites/default/',
  ),
);
EOL

  #Now add drupal console aliases.
  cat >> $user_home/.console/sites/$folder.yml <<EOL
$sn:
  root: $site_path/$sn
  type: local
EOL

done
IFS=$Field_Separator

#Finish the Drush alias file with
echo "?>" >> "$user_home/.drush/$folder.aliases.drushrc.php"

# Now convert it to drush 9 yml
drush sac "$user_home/.drush/sites/" -q

sn=$storesn
}

fix_site_settings () {
# This will fix the site settings
# Presumes the following information is set
# $user
# $folder
# $sn
# $webroot
# $site_path

# Check that settings.php has reference to local.settings.php
echo "Making sure settings.php exists"
if [ -f "$site_path/$sn/$webroot/sites/default/settings.php.old" ]
then
#      cp "$site_path/$sn/$webroot/sites/default/settings.php.old" "$site_path/$sn/$webroot/sites/default/settings.php"
   # get rid of any old settings.php
rm "$site_path/$sn/$webroot/sites/default/settings.php.old"
fi


if [ ! -f "$site_path/$sn/$webroot/sites/default/settings.php" ]
then
if [ ! -f "$site_path/$sn/$webroot/sites/default/default.settings.php" ]
then
wget "https://git.drupalcode.org/project/drupal/raw/8.8.x/sites/default/default.settings.php" -P "$site_path/$sn/$webroot/sites/default/"
fi
#    echo "$site_path/$sn/$webroot/sites/default/default.settings.php does not exist. Please add it and try again."
#    exit 1

  cp "$site_path/$sn/$webroot/sites/default/default.settings.php" "$site_path/$sn/$webroot/sites/default/settings.php"

fi

sfile=$(<"$site_path/$sn/$webroot/sites/default/settings.php")
echo "sfile: "$site_path/$sn/$webroot/sites/default/settings.php""
if [[ $sfile =~ (\{[[:space:]]*include) ]]
then
echo "settings.php is correct"
else
echo "settings.php: added reference to settings.local.php"
cat >> $site_path/$sn/$webroot/sites/default/settings.php <<EOL
 if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }

EOL
fi


cat > $site_path/$sn/$webroot/sites/default/settings.local.php <<EOL
<?php

\$settings['install_profile'] = '$profile';
\$settings['file_private_path'] =  '../private';
\$databases['default']['default'] = array (
  'database' => '$db',
  'username' => '$dbuser',
  'password' => '$dbpass',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\Core\Database\Driver\mysql',
  'driver' => 'mysql',
);
\$config_directories[CONFIG_SYNC_DIRECTORY] = '../cmi';
EOL
if [ "$dev" == "y" ]
then
cat >> $site_path/$sn/$webroot/sites/default/settings.local.php <<EOL
\$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
\$settings['cache']['bins']['render'] = 'cache.backend.null';
\$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
\$config['config_split.config_split.config_dev']['status'] = TRUE;
EOL
fi

#Add site name
if [  "$sitename" != "default" ]
then
echo "\$config['system.site']['name'] = \"$sitename\"; " >>  "$site_path/$sn/$webroot/sites/default/settings.local.php"
fi

echo "Added settings.local.php to $sn"

#echo "Make sure the hash is present so drush sql will work in $site_path/$sn/$webroot/sites/default/."
# Make sure the hash is present so drush sql will work.
#cd "$site_path/$sn/$webroot"

#remove empty hash_salt if it exists
 sed -i "s/\$settings\['hash_salt'\] = '';//g" "$site_path/$sn/$webroot/sites/default/settings.php"
sfile=$(<"$site_path/$sn/$webroot/sites/default/settings.php")
slfile=$(<"$site_path/$sn/$webroot/sites/default/settings.local.php")
#echo "sfile $site_path/$sn/$webroot/sites/default/settings.php  slfile $site_path/$sn/$webroot/sites/default/settings.local.php"

if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]
then
#  echo "settings.php does not have hash_salt"
if [[ ! $slfile =~ (\'hash_salt\'\] = \') ]]
then
#    echo "settings.local.php does not have hash_salt"
  hash=$(echo -n $RANDOM | md5sum)
  hash2=$(echo -n $RANDOM | md5sum)
  hash="${hash::-3}${hash2::-3}"
  hash="${hash:0:55}"
# The line below causes an error since drush may not be called from webroot or above, hence the code above.
#  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
echo "\$settings['hash_salt'] = '$hash';" >> "$site_path/$sn/$webroot/sites/default/settings.local.php"
echo "Added hash salt"
fi
fi


}
ocmsg () {
# This is to provide extra messaging if the verbose variable in pl.yml is set to y.
if [ "$verbose" == "y" ]
then
echo $1
fi
}

set_site_permissions () {
# This will set the correct permissions
# Presumes the following information is set
# $user
# $folder
# $sn
# $webroot
if [ $dev = "y" ] ; then devp="--dev" ; fi ;

sudo d8fp.sh --drupal_path="$site_path/$sn/$webroot" --drupal_user=$user --httpd_group=www-data $devp

}



rebuild_site () {
#This will delete current site database and rebuild it
# Persumes the following information is set
# $user
# $folder
# $sn
# $webroot
#etc
echo "bstep $bstep"
if [ -z $bstep ] ; then bstep=1 ; fi
echo "bstep $bstep"

if [ $bstep -gt 1 ] ; then
  echo "Starting from build step $step"
fi
echo "Create database and user if needed."
if [ $bstep -lt 2 ] ; then
echo -e "$Purple build step 1: create the database $Color_Off"
make_db
fi

if [ $bstep -lt 3 ] ; then
echo -e "$Purple build step 2: Build the drupal site $sn $Color_Off"

# drush status
site_info
# drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
cd $site_path/$sn/$webroot

#echo "drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sn" --sites-subdir=default"

drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sn" --sites-subdir=default
#don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.
fi

if [ $bstep -lt 4 ] ; then
echo -e "$Purple build step 3: set site permissions $Color_Off"
#sudo bash ./d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user #shouldn't need this, since files don't need to be changed.
#chmod g+w -R $folder/$webroot/modules/custom
set_site_permissions
fi

if [ $bstep -lt 5 ] ; then
echo -e "$Purple build step 4: install composer console $Color_Off"
# Install any themes
cd $site_path/$sn/
composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader
fi

if [ $bstep -lt 6 ] ; then
echo -e "$Purple build step 5: install themes if required $Color_Off"
if [ $theme != "" ]
then
echo "Install theme for $sn using uri $uri and theme $theme"

cd $site_path/$sn/$webroot
drupal --target=$uri theme:install  $theme
drush @$sn config-set system.theme default $theme -y
fi

if [ $theme_admin != "" ]
then
echo "Install theme for $sn"
cd $site_path/$sn/$webroot
drupal --target=$uri theme:install  $theme_admin
drush @$sn config-set system.theme admin $theme_admin -y
fi
#drush cr #is this needed here?
drush @$sn cr
fi
###

#  if [ "$dev" = "y" ]
#  then
#  drush en -y oc_dev
#  #uninstall the wrapper. Will leave all dependencies installed.
#  drush pm-uninstall -y oc_dev
#  else
#  drush en -y oc_prod
#  fi

if [ $bstep -lt 7 ] ; then
echo -e "$Purple build step 6: install modules $Color_Off"

if [ "$install_modules" != "" ]
then
echo "Install modules for $sn"
drush @$sn en -y $install_modules
fi
fi

#drush pm-uninstall -y oc_prod
if [ $bstep -lt 8 ] ; then
echo -e "$Purple build step 7: set to dev or production mode $Color_Off"
if [ "$dev" == "y" ]
then
echo "Setting to dev mode"
drupal --target=$uri site:mode dev
drush @$sn php-eval 'node_access_rebuild();'
drush @$sn en -y $dev_modules
else
drupal --target=$uri site:mode prod
fi
fi
}

backup_site () {
#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
cd
# Check if site backup folder exists
if [ ! -d "$folderpath/sitebackups" ]; then
  mkdir "$folderpath/sitebackups"
fi

# Check if site backup folder exists
if [ ! -d "$folderpath/sitebackups/$sn" ]; then
  mkdir "$folderpath/sitebackups/$sn"
fi


if [ ! -d "$site_path/$sn" ]; then
  echo "No site folder $sn so no need to backup"
else
cd "$site_path/$sn"
#this will not affect a current git present
git init
cd "$webroot"
msg="${msg// /_}"
Name=$(date +%Y%m%d\T%H%M%S-)`git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g'`-`git rev-parse HEAD | cut -c 1-8`$msg.sql

echo -e "\e[34mbackup db $Name\e[39m"
# Make database smaller.
drush cr
# Could add more directives to make database even smaller.
drush sql-dump --result-file="$folderpath/sitebackups/$sn/$Name"

#backupfiles
Name2=${Name::-4}".tar.gz"

echo -e "\e[34mbackup files $Name2\e[39m"
cd $site_path
tar -czf $folderpath/sitebackups/$sn/$Name2 $sn
fi
}

backup_prod () {
#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
sn="prod"
msg=${1// /_}
cd
# Check if site backup folder exists
if [ ! -d "$folder/sitebackups/$sn" ]; then
  mkdir "$folder/sitebackups/$sn"
fi

#cd "$webroot"

#Name="$folderpath/sitebackups/prod/prod$(date +%Y%m%d\T%H%M%S-)$msg"
Name="prod$(date +%Y%m%d\T%H%M%S-)$msg"
Namesql="$folderpath/sitebackups/prod/$Name.sql"
echo -e "\e[34mbackup db $Name.sql\e[39m"
echo "Trying $Namesql "
#drush @prod sql-dump   > "$Namesql"
drush @prod sql-dump  --result-file="/home/$prod_user/$Name.sql"
scp "$prod_alias:$Name.sql" "$folderpath/sitebackups/prod/$Name.sql"
#gzip -d "$Namesql.gz"

Namef=$Name.tar.gz
echo -e "\e[34mbackup files $Namef\e[39m"
if [ $prod_method == "tar" ]
then
# drush ard doesn't work in drush 9 onwards. so use tar instead
#drush @prod ard --destination="$prod_docroot/../../../$Name"
ssh $prod_alias "tar --exclude='$prod_docroot/sites/default/settings.local.php' --exclude='$prod_docroot/sites/default/settings.php' -zcf \"$Namef\" \"$prod_docroot/..\""
scp "$prod_alias:$Namef" "$folderpath/sitebackups/prod/$Namef"
#tar -czf  $folderpath/sitebackups/prod/$Name.tar.gz $folderpath/sitebackups/prod/$Name.tar
#rm $folderpath/sitebackups/prod/$Name.tar
else
# presume git
# This needs work. It's not tested!
ssh $prod_alias "cd $prod_docroot/.. & addc & git add . & git commit -m \"preupdate\" & git push"
fi

}

backup_db () {
echo -e "$Green backing up $sn $Color_Off"

#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
# Check if site backup folder exists
if [ ! -d "$folderpath/sitebackups/$sn" ]; then
  mkdir "$folderpath/sitebackups/$sn"
fi
cd
cd "$site_path/$sn"
#this will not affect a current git present
git init
cd "$webroot"
msg=${1// /_}
Name=$(date +%Y%m%d\T%H%M%S-)`git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g'`-`git rev-parse HEAD | cut -c 1-8`$msg.sql
echo -e "\e[34mbackup db $Name\e[39m"
drush @$sn sset system.maintenance_mode TRUE
drush @$sn sql-dump --result-file="$folderpath/sitebackups/$sn/$Name"
drush @$sn sset system.maintenance_mode FALSE

}
make_db () {
echo "Create database $db and user $dbuser if needed."
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "use $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" != ": 0" ]
 then
  echo "The database $db does not exist. I will try to create it."
  if ! mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; then
    # This script actually just tries to create the user since the database will be created later anyway.
    echo "Unable to create the database $db. Check the mysql root credentials in mysql.cnf"
    exit 1
    else
    echo "Database $db created."
  fi
  else
  echo "Database $db exists so I will drop it."
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Database $db dropped"; else echo "Could not drop database $db: exiting"; exit 1; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created database $db using user root"; else echo "Could not create database $db using user root, exiting"; exit 1; fi
fi

  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created user $dbuser"; else echo "User $dbuser already exists"; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '"$dbuser"'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Granted user $dbuser permissions on $db"; else echo "Could not grant user $dbuser permissions on $db"; fi

}
restore_db () {
#presumes that the correct information is already set
# $Name backup sql file
# $db
# $dbuser
# $dbpass
echo "restore db start"

make_db

echo -e "\e[34mrestore $db database using $folderpath/sitebackups/$bk/$Name\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" $db < "$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Backup database $Name imported into database $db using root"; else echo "Could not import $Name into database $db using root, exiting"; exit 1; fi
drush @$sn cr
drush @$sn sset system.maintenance_mode TRUE
}

test_site () {
echo $sn, $db, $dbuser, $dbpass
}

db_defaults () {
# Database defaults
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
if [ -z ${db+x} ]
then
    db="$sn$folder"
fi
if [ -z ${dbuser+x} ]
then
    dbuser=$db
fi
if [ -z ${dbpass+x} ]
then
    dbpass=$dbuser
fi
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
}

site_info () {
echo "Source  = $project"
echo "Project folder = $folder"
echo "Site folder = $sn"
echo "webroot = $webroot"
echo "Profile  = $profile"
echo "uri      = $uri"
echo "Dev      = $dev"
echo "Private folder = $private"
echo "Database = $db"
echo "Database user = $dbuser"
echo "Database password = $dbpass"
echo "Install method = $install_method"
echo "git_upstream = $git_upstream"
echo "theme = $theme"
echo "admin theme = $theme_admin"
echo "install_modules = $install_modules"
echo "dev_modules = $dev_modules"
}

copy_site_files () {
from=$1
sn=$2
echo "From $from to $sn"


#We need to work out where each site is.
import_site_config $from
from_sp=$site_path
import_site_config $sn
to_sp=$site_path

if [ -d $to_sp/$sn ]
then
sudo chown $user:www-data $to_sp/$sn -R
chmod +w $to_sp/$sn -R
rm -rf $to_sp/$sn
fi
echo "Move all files from $from to $sn"
cp -rf "$from_sp/$1" "$to_sp/$2"
}

copy_site_folder () {
from=$1
sn=$2
echo "Copy site folder from $from to $sn"

if [ -d $site_path/$sn/$webroot/sites ]
then
chown $user:www-data $site_path/$sn/$webroot/sites -R
chmod +w $site_path/$sn/$webroot/sites -R
rm -rf $site_path/$sn/$webroot/sites
fi

echo -e "\e[34mcopy private files from $from\e[39m"
rm -rf $site_path/$sn/private
cp -rf "$site_path/$from/private" "$site_path/$sn/private"
cp -rf "$site_path/$from/$webroot/sites" "$site_path/$sn/$webroot/sites"

}
