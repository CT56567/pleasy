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
echo "No site install profile given."
exit 0
else
profile=$2
fi

if [ -z "$3" ] ; then
echo "No user given"
exit 0
else
user=$3
fi

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)

echo "Update Production"
echo "Site: $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"
echo "Profile: profile"

dbname=$(date +%N | sha256sum | base64 | head -c 32 ; echo)
dbuser=$(date +%N | sha256sum | base64 | head -c 32 ; echo)
dbpass=$(date +%N | sha256sum | base64 | head -c 32 ; echo)
#echo "database: $dbname $dbuser $dbpass"
# Check that settings.php has reference to local.settings.php
  echo "Fixing settings at $prod_docroot"
  echo "Making sure settings.php exists"
  if [ -f "$prod_docroot/sites/default/settings.php.old" ]; then
    #cp "$prod_docroot/sites/default/settings.php.old" "$prod_docroot/sites/default/settings.php"
    # get rid of any old settings.php
    rm "$prod_docroot/sites/default/settings.php.old"
  fi

  if [ ! -f "$prod_docroot/sites/default/settings.php" ]; then
    if [ ! -f "$prod_docroot/sites/default/default.settings.php" ]; then
      wget "https://git.drupalcode.org/project/drupal/raw/9.2.x/sites/default/default.settings.php" -P "$prod_docroot/sites/default/"
    fi
    #    echo "$prod_docroot/sites/default/default.settings.php does not exist. Please add it and try again."
    #    exit 1

    cp "$prod_docroot/sites/default/default.settings.php" "$prod_docroot/sites/default/settings.php"
  fi

# Don't use settings.local.php so it's not copied!

  cat >$prod_docroot/sites/default/settings.php <<EOL
<?php
\$databases = [];
\$settings['update_free_access'] = FALSE;
\$settings['container_yamls'][] = \$app_root . '/' . \$site_path . '/services.yml';
\$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];
\$settings['entity_update_batch_size'] = 50;
\$settings['entity_update_backup'] = TRUE;
\$settings['migrate_node_migrate_type_classic'] = FALSE;

\$settings['install_profile'] = '$profile';
\$settings['file_private_path'] =  '../private';
\$databases['default']['default'] = array (
  'database' => '$dbname',
  'username' => '$dbuser',
  'password' => '$dbpass',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\Core\Database\Driver\mysql',
  'driver' => 'mysql',
);
\$settings["config_sync_directory"] = '../cmi';
\$config['config_split.config_split.config_dev']['status'] = FALSE;
\$config['system.site']['name'] = \"$uri\";
EOL

  echo "Added settings.php to $sitename_var"

  #echo "Make sure the hash is present so drush sql will work in $prod_docroot/sites/default/."
  # Make sure the hash is present so drush sql will work.
  #cd "$prod_docroot"
  #remove empty hash_salt if it exists
  sed -i "s/\$settings\['hash_salt'\] = '';//g" "$prod_docroot/sites/default/settings.php"
  sfile=$(<"$prod_docroot/sites/default/settings.php")

  #echo "sfile $prod_docroot/sites/default/settings.php  slfile $prod_docroot/sites/default/settings.local.php"

  if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]; then
    #  echo "settings.php does not have hash_salt"

      hash=$(echo -n $RANDOM | md5sum)
      hash2=$(echo -n $RANDOM | md5sum)
      hash="${hash::-3}${hash2::-3}"
      hash="${hash:0:55}"
      # The line below causes an error since drush may not be called from webroot or above, hence the code above.
      #  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
      echo "\$settings['hash_salt'] = '$hash';" >>"$prod_docroot/sites/default/settings.php"
      echo "Added hash salt"

  fi


# Now store the files
echo "storing the settings file"
sudo cp "$prod_docroot/sites/default/settings.php" ~/$uri/settings.php

echo "Creating the database."
cd ~/$uri
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '"$dbpass"';"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "DROP DATABASE $dbname;"
mysql --defaults-extra-file=/home/$user/mysql.cnf -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql --defaults-extra-file=/home/$user/mysql.cnf $dbname < prod.sql

echo "Site setup finished."