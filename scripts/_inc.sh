#!/bin/bash
#                     Included functions For Pleasy Library
#
#  @ROB add description to this script and to the print_help function!
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  29/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
#                                TODO LIST
#

# oc includes
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479

#
#
myreadlink() {
  if [ ! -h "$1" ]; then
    echo "$1"
  else
    (
      local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"
      cd $(dirname $1)
      myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"
    )
  fi
}

whereis() {
  echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"
}

whereis_realpath() {
  local SCRIPT_PATH=$(whereis $1)
  myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"
}

# Modified from: https://gist.github.com/aamnah/f03c266d715ed479eb46
#COLORS
# Reset
Color_Off='\033[0m' # Text Reset

# Regular Colors
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan

# Should use more descriptive colors for messages
Alert='\033[0;31m' # Red
Warn='\033[0;33m'  # Yellow

#
#
import_site_config() {
  # setup basic defaults
  sitename_var=$1
  stage=""
  sitename_store=$1
  if [ "${sitename_var:0:3}" = "stg" ]; then
    # set up stg
    sitename_var=${sitename_var:4}
    stage="stg_"
  fi
  ocmsg "short ${sitename_var:0:4} normal $sitename_var new sitename ${sitename_var:5}" debug
  if [ "${sitename_var:0:4}" = "prod" ]; then
    # set up stg
    sitename_var=${sitename_var:5}
    stage="prod_"
  fi

  # First load the defaults
  rp="recipes_default_source"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    project=${!rp}
  else
    project=""
  fi
  rp="recipes_default_dev"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dev=${!rp}
  else
    dev=""
  fi
  rp="recipes_default_webroot"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    webroot=${!rp}
  else
    webroot=""
  fi
  rp="recipes_default_sitename"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    sitename=${!rp}
  else
    sitename=""
  fi
  rp="recipes_default_auto"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    auto=${!rp}
  else
    auto=""
  fi
  rp="recipes_default_apache"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    apache=${!rp}
  else
    apache=""
  fi
  rp="recipes_default_dbuser"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dbuser=${!rp}
  else
    dbuser=""
  fi
  rp="recipes_default_profile"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    profile=${!rp}
  else
    profile=""
  fi
  rp="recipes_default_db"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    db=${!rp}
  else
    db=""
  fi
  rp="recipes_default_dbpass"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dbpass=${!rp}
  else
    dbpass=""
  fi
  rp="recipes_default_lando"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    lando=${!rp}
  else
    lando=""
  fi
  rp="recipes_default_uri"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    if [ "$lando" == "y" ]; then
      uri="${!rp}.lndo.site"
    else
      uri=${!rp}
    fi
  else
    if [ "$lando" == "y" ]; then
      uri="$sitename_var.lndo.site"
    else
      uri="$folder.$sitename_var"
    fi
  fi
  rp="recipes_default_install_method"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    install_method=${!rp}
  else
    install_method=""
  fi
  rp="recipes_default_git_upstream"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    git_upstream=${!rp}
  else
    git_upstream=""
  fi
  rp="recipes_default_theme"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    theme=${!rp}
  else
    theme=""
  fi
  rp="recipes_default_theme_admin"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    theme_admin=${!rp}
  else
    theme_admin=""
  fi
  rp="recipes_default_install_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    install_modules=${!rp}
  else
    install_modules=""
  fi
  rp="recipes_default_reinstall_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    reinstall_modules=${!rp}
  else
    reinstall_modules=""
  fi
  rp="recipes_default_dev_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dev_modules=${!rp}
  else
    dev_modules=""
  fi

  # Collect the details from pl.yml if they exist otherwise make blank This
  # first one is to override the defaults, ie default= n so if a site wants to
  # leave it blank, but the default has a value, it will be left blank.  Though
  # some values need to have a value and so if blank will get their values from
  # the default recipe.
  rb="recipes_${sitename_var}_default"
  rp="recipes_${sitename_var}_source"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    project="${!rp}"
  fi
  rp="recipes_${sitename_var}_dev"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dev=${!rp}
  fi
  rp="recipes_${sitename_var}_webroot"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    webroot="${!rp}"
  fi
  rp="recipes_${sitename_var}_sitename"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    sitename=${!rp}
  fi
  rp="recipes_${sitename_var}_auto"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    auto=${!rp}
  fi
  rp="recipes_${sitename_var}_apache"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    apache=${!rp}
  fi
  rp="recipes_${sitename_var}_dbuser"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dbuser=${!rp}
  elif [ "${!rb}" == "n" ]; then
    dbuser=""
  fi
  rp="recipes_${sitename_var}_profile"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    profile=${!rp}
  fi
  rp="recipes_${sitename_var}_db"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    db=${!rp}
  elif [ "${!rb}" == "n" ]; then
    db=""
  fi
  rp="recipes_${sitename_var}_dbpass"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dbpass=${!rp}
  elif [ "${!rb}" == "n" ]; then
    dbpass=""
  fi
  rp="recipes_${sitename_var}_uri"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    uri=${!rp}
  fi
  rp="recipes_${sitename_var}_install_method"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    install_method=${!rp}
  fi
  rp="recipes_${sitename_var}_git_upstream"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    git_upstream=${!rp}
  elif [ "${!rb}" == "n" ]; then
    git_upstream=""
  fi
  rp="recipes_${sitename_var}_theme"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    theme=${!rp}
  elif
    [ "${!rb}" == "n" ]
  then theme=""; fi
  rp="recipes_${sitename_var}_theme_admin"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    theme_admin=${!rp}
  elif [ "${!rb}" == "n" ]; then
    theme_admin=""
  fi
  rp="recipes_${sitename_var}_install_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    install_modules=${!rp}
  elif [ "${!rb}" == "n" ]; then
    install_modules=""
  fi
  rp="recipes_${sitename_var}_reinstall_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    reinstall_modules=${!rp}
  elif [ "${!rb}" == "n" ]; then
    reinstall_modules=""
  fi
  rp="recipes_${sitename_var}_dev_modules"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dev_modules=${!rp}
  elif [ "${!rb}" == "n" ]; then
    dev_modules=""
  fi
  rp="recipes_${sitename_var}_dev_composer"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    dev_composer=${!rp}
  elif [ "${!rb}" == "n" ]; then
    dev_composer=""
  fi
  rp="recipes_${sitename_var}_lando"
  rpv=${!rp}
  if [ "$rpv" != "" ]; then
    lando=${!rp}
  fi

  if [[ "$stage" == "stg_" || "$stage" == "prod_" ]]; then
    db=""
    dbuser=""
    dbpass=""
    dev="n"
    uri="pleasy.$stage$sitename_var"
    # Not sure about gitupstream
    #now set the sitename
    sitename_var=$sitename_store
  fi

  if [ "$db" = "" ]; then
    db="$sitename_var$folder"
  fi
  if [ "$dbuser" = "" ]; then
    dbuser=$db
  fi
  if [ "$dbpass" = "" ]; then
    dbpass=$dbuser
  fi

  if [[ "$sitename" == "" ]]; then
    sitename="$sitename_var"
  fi

  if [ "$lando" = "y" ]; then
    folder=$(basename $(dirname $script_root))
    private="/home/$user/$folder/$sitename_var/private"
    site_path="/home/$user/$folder"
  else
    folder=$(basename $(dirname $script_root)) # should be correct ?? @rjzaar
    private="$www_path/$sitename_var/private"
    site_path="$www_path"
  fi

  # Create stg site

  # Clear all prod variables
  prod_alias=""
  prod_docroot=""
  prod_gitdb=""
  prod_gitkey=""
  prod_gitrepo=""
  prod_method=""
  prod_reinstall_modules=""
  prod_test_docroot=""
  prod_test_uri=""
  prod_uri=""
  prod_user=""

  # Allow for getting prod information for stg site.
  if [ "$stage" = "stg_" ]; then
    store_sitename=$sitename_var
    sitename_var=${sitename_var:4}
  fi
  if [ "$stage" = "prod_" ]; then
    store_sitename=$sitename_var
    sitename_var=${sitename_var:5}
  fi
  ocmsg "Working out prod creds sitename is $sitename_var" debug

  rp="recipes_${sitename_var}_prod_user"
  rpv=${!rp}
  if [[ "$rpv" != "" ]]; then
    #make all the prod variables based on the site variables
    # this is a quick workaround.
    rp="recipes_${sitename_var}_prod_alias"
    rpv=${!rp}
    ocmsg "$rp $rpv" debug
    if [ "$rpv" != "" ]; then
      prod_alias=${!rp}
    fi
    rp="recipes_${sitename_var}_prod_docroot"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_docroot=${!rp}
    fi
    rp="recipes_${sitename_var}_prod_gitdb"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_gitdb=${!rp}
    fi
    rp="recipes_${sitename_var}_prod_gitkey"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_gitkey=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_gitrepo"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_gitrepo=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_method"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_method=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_reinstall_modules"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_reinstall_modules=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_test_docroot"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_test_docroot=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_test_uri"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_test_uri=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_uri"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_uri=${!rp}
    fi

    rp="recipes_${sitename_var}_prod_user"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      prod_user=${!rp}
    fi
  fi

  # swap name back
  if [ "$stage" = "stg_" ]; then
    sitename_var=$store_sitename
  fi
  if [ "$stage" = "prod_" ]; then
    sitename_var=$store_sitename
  fi
}

# Called all the time
# Import yaml, which provides global variables. presumes $script_root is set
# SCRIPT IS BROKEN FOR JAMES
parse_pl_yml() {
  # $userhome
  update_config="n"

  . $script_root/scripts/parse_yaml.sh "pl.yml" $script_root
  # Project is no longer set in pl.yml. It is collected from the context.
  project=$folder
  if [ $update_config == "y" ]; then
    # If parse_pl_yml is being called from init.sh (ie for the first time) then we don't want update_all_configs being run
    # since there is no need to update them since it is bring run for the first time. update_all_configs is set to false
    # before the end of init.sh
    if [ ! -z "$no_config_update" ]; then
      update_all_configs
    elif [ "$no_config_update" != "true" ]; then
      update_all_configs
    fi
  fi
  ocmsg "Completed parse_pl_yml" debug
}

#
#
update_all_configs() {
  echo "update configs"

  # Don't know where user_home gets it, but it ends with '/.' which needs to be removed
  ocmsg "user_home before: $user_home  folderpath: $folderpath" debug
  if [ "${user_home:(-2)}" == "/." ]; then
    user_home="${user_home:0:-2}"
  fi
  ocmsg "user_home after: $user_home" debug
  # Update all database credentials in case the user changed any.
  # Create a list of recipes
  for f in $recipes_; do
    recipes="$recipes,${f#*_}"
    ocmsg "update_all_configs:recipes: $f" debug
    # pl is reserved to pleasy itself. This is for gcom to commit pl commits to pleasy
    if [[ "$f" == "recipes_pl" ]]; then
      echo "pl can't be used for a recipe. It is a reserved keyword for pleasy itself."
      exit 1
    fi
  done
  recipes=${recipes#","}
  ocmsg "recipes collected" debug
  ocmsg "user_home: $user_home" debug
  # Store the site name to restore it later
  storesn=$sitename_var

  # Setup drupal console if it is installed.
  drupalconsole="y"

  # Create drupal console file
  if [ ! -d "$user_home/.console" ]; then
    ocmsg "Drupal console is not installed."
    mkdir $user_home/.console
    mkdir $user_home/.console/sites
    drupalconsole="n"
  elif [ ! -d $user_home/.console/sites ]; then
    ocmsg "make dir $user_home/.console/sites" debug
    mkdir $user_home/.console/sites
  fi
  # Clear current file
  ocmsg "console location: $user_home/.console/sites/$folder.yml"
  if [ -f "$user_home/.console/sites/$folder.yml" ]; then
    echo "" >"$user_home/.console/sites/$folder.yml"
  fi

  cd $folderpath

  #Collect the drush location: messy but it works!
  # This command might list some warnings. It is a bug with drush: https://github.com/drush-ops/drush/issues/3226

  ocmsg "Drush tmp: $folderpath/drush.tmp" debug
  source ~/.bashrc
  ocmsg "drush core:init" debug
  drush core:init -y
  source ~/.bashrc
  ocmsg "drush status" debug
  drush status
  #  if [[ $folderpath/drush.tmp =~ (@loc) ]] ; then
#  drush @loc status >"$folderpath/drush.tmp"
  #  else
  drush status >"$folderpath/drush.tmp"
  #  fi

  ocmsg "Add correct drush path" debug
  dline=$(awk 'match($0,v){print NR; exit}' v="Drush script" "$folderpath/drush.tmp")
  dlinec=$(sed "${dline}q;d" "$folderpath/drush.tmp")
  dlined="/$(echo "${dlinec#*/}")"
  drushloc=${dlined::-11}
  rm "$folderpath/drush.tmp"

  if [ -f $user_home/.drush/$folder.aliases.drushrc.php ]; then
    rm $user_home/.drush/$folder.aliases.drushrc.php
  fi

  ocmsg "Create drush aliases" debug

  ocmsg "Delete old credentials folder if it exists" debug
  if [ -d $folderpath/credentials ]; then rm $folderpath/credentials -rf; fi
  mkdir $folderpath/credentials

  ocmsg "Now go through each site and create settings for each site." debug
  Field_Separator=$IFS
  # set comma as internal field separator for the string list
  IFS=,

  cat >$user_home/.drush/$folder.aliases.drushrc.php <<EOL
  <?php
  /**
  * This file has been created by $site_folder/scripts/_inc.sh
  *
  */
EOL

  for site in $recipes; do
    # Database defaults
    rp="recipes_${site}_db"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then
      sdb=${!rp}
    else
      sdb="$site$folder"
    fi
    rp="recipes_${site}_dbuser"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then sdbuser=${!rp}; else sdbuser=$sdb; fi
    rp="recipes_${site}_dbpass"
    rpv=${!rp}
    if [ "$rpv" != "" ]; then sdbpass=${!rp}; else sdbpass=$sdbuser; fi

    cat >$(dirname $script_root)/credentials/$site.mysql <<EOL
[client]
user = $sdbuser
password = $sdbpass
host = localhost
EOL

    #Now go through and create a Drush Alias for each site
    import_site_config $site

    cat >>$user_home/.drush/$folder.aliases.drushrc.php <<EOL
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
    salias="recipes_${site}_prod_alias"
    hasalias=${!salias}
#    echo "salias $salias hasalias $hasalias"
    if [[ ! "$hasalias" == "" ]]; then
      cat >>$user_home/.drush/$folder.aliases.drushrc.php <<EOL
\$aliases['prod_$site'] = array (
'uri' => '$prod_uri',
'root' => '$prod_docroot',
'remote-user' => '$prod_user',
'remote-host' => '$prod_uri',
);
\$aliases['test_$site'] = array (
'uri' => '$prod_test_uri',
'root' => '$prod_test_docroot',
'remote-user' => '$prod_user',
'remote-host' => '$prod_uri',
);
EOL
    fi
    #Now add drupal console aliases.
    cat >>$user_home/.console/sites/$folder.yml <<EOL
$sitename_var:
  root: $site_path/$sitename_var
  type: local
EOL
    ### repeat for the stage site ####
    site="stg_$site"
    # Database defaults
    sdb="stg_$sitename_var$folder"
    sdbuser=$sdb
    sdbpass=$sdb

    cat >$(dirname $script_root)/credentials/$site.mysql <<EOL
[client]
user = $sdbuser
password = $sdbpass
host = localhost
EOL

    #Now go through and create a Drush Alias for each site
    import_site_config $site

    cat >>$user_home/.drush/$folder.aliases.drushrc.php <<EOL
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
    cat >>$user_home/.console/sites/$folder.yml <<EOL

    ### END repeat for the stage site ####
$sitename_var:
  root: $site_path/$sitename_var
  type: local
EOL

  done
  IFS=$Field_Separator

  #Finish the Drush alias file with
  echo "?>" >>"$user_home/.drush/$folder.aliases.drushrc.php"

  # Now convert it to drush 9 yml
  drush sac "$user_home/.drush/sites/" -q

  sitename_var=$storesn
}

# This will fix the site settings
# Presumes the following information is set:
# $user
# $folder
# $sitename_var
# $webroot
# $site_path
fix_site_settings() {

  # Check that settings.php has reference to local.settings.php
  echo "Fixing settings at $site_path/$sitename_var/$webroot"
  echo "Making sure settings.php exists"
  uri="pleasy.$sitename_var"
  if [ -f "$site_path/$sitename_var/$webroot/sites/default/settings.php.old" ]; then
    #cp "$site_path/$sitename_var/$webroot/sites/default/settings.php.old" "$site_path/$sitename_var/$webroot/sites/default/settings.php"
    # get rid of any old settings.php
    rm "$site_path/$sitename_var/$webroot/sites/default/settings.php.old"
  fi

  if [ ! -f "$site_path/$sitename_var/$webroot/sites/default/settings.php" ]; then
    if [ ! -f "$site_path/$sitename_var/$webroot/sites/default/default.settings.php" ]; then
      wget "https://git.drupalcode.org/project/drupal/raw/8.8.x/sites/default/default.settings.php" -P "$site_path/$sitename_var/$webroot/sites/default/"
    fi
    #    echo "$site_path/$sitename_var/$webroot/sites/default/default.settings.php does not exist. Please add it and try again."
    #    exit 1

    cp "$site_path/$sitename_var/$webroot/sites/default/default.settings.php" "$site_path/$sitename_var/$webroot/sites/default/settings.php"
  fi

  sfile=$(<"$site_path/$sitename_var/$webroot/sites/default/settings.php")
  echo "sfile: "$site_path/$sitename_var/$webroot/sites/default/settings.php""
  if [[ $sfile =~ (\{[[:space:]]*include) ]]; then
    echo "settings.php is correct"
  else
    echo "settings.php: added reference to settings.local.php"
    cat >>$site_path/$sitename_var/$webroot/sites/default/settings.php <<EOL
 if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }

EOL
  fi
  if [[ "$lando" == "y" ]]; then
    cat >$site_path/$sitename_var/$webroot/sites/default/settings.local.php <<EOL
  <?php
  \$settings['install_profile'] = '$profile';
  \$databases['default']['default'] = [
  'database' => 'drupal8',
  'username' => 'drupal8',
  'password' => 'drupal8',
  'prefix' => '',
  'host' => 'database',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];
EOL
  else
    cat >$site_path/$sitename_var/$webroot/sites/default/settings.local.php <<EOL
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
\$settings["config_sync_directory"] = '../cmi';
\$settings['trusted_host_patterns'] = [
  '^www\.test\.${uri//./\\.}$',
  '^test\.${uri//./\\.}$',
  '^www\.${uri//./\\.}$',
  '^${uri//./\\.}$',
];

EOL
  fi
  if [ "$dev" == "y" ]; then
    cat >>$site_path/$sitename_var/$webroot/sites/default/settings.local.php <<EOL
\$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
\$settings['cache']['bins']['render'] = 'cache.backend.null';
\$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
\$config['config_split.config_split.config_dev']['status'] = TRUE;
EOL
  else
    cat >>$site_path/$sitename_var/$webroot/sites/default/settings.local.php <<EOL
\$config['config_split.config_split.config_dev']['status'] = FALSE;
#if (PHP_SAPI !== 'cli') {
#  $settings['config_readonly'] = TRUE;
#}
EOL
  fi

  #Add site name
  if [ "$sitename" != "default" ]; then
    echo "\$config['system.site']['name'] = \"$sitename\"; " >>"$site_path/$sitename_var/$webroot/sites/default/settings.local.php"
  fi

  echo "Added settings.local.php to $sitename_var"

  #echo "Make sure the hash is present so drush sql will work in $site_path/$sitename_var/$webroot/sites/default/."
  # Make sure the hash is present so drush sql will work.
  #cd "$site_path/$sitename_var/$webroot"

  #remove empty hash_salt if it exists
  sed -i "s/\$settings\['hash_salt'\] = '';//g" "$site_path/$sitename_var/$webroot/sites/default/settings.php"
  sfile=$(<"$site_path/$sitename_var/$webroot/sites/default/settings.php")
  slfile=$(<"$site_path/$sitename_var/$webroot/sites/default/settings.local.php")
  #echo "sfile $site_path/$sitename_var/$webroot/sites/default/settings.php  slfile $site_path/$sitename_var/$webroot/sites/default/settings.local.php"

  ################################################################################
  # IDE says these lines are broken, are they working as intended?

  if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]; then
    #  echo "settings.php does not have hash_salt"
    if [[ ! $slfile =~ (\'hash_salt\'\] = \') ]]; then
      #    echo "settings.local.php does not have hash_salt"
      hash=$(echo -n $RANDOM | md5sum)
      hash2=$(echo -n $RANDOM | md5sum)
      hash="${hash::-3}${hash2::-3}"
      hash="${hash:0:55}"
      # The line below causes an error since drush may not be called from webroot or above, hence the code above.
      #  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
      echo "\$settings['hash_salt'] = '$hash';" >>"$site_path/$sitename_var/$webroot/sites/default/settings.local.php"
      echo "Added hash salt"
    fi
  fi

  # Now make sure files have correct permissions - this is a lot faster than fixp
  sudo chown $user:www-data $site_path/$sitename_var -R

}

#
# ocmsg replaces echo and gives some options. The default is "none" which is set by each script at the start of the
# command. Options can be passed to the command for ocmsg to provide information
# normal: To provide information about what is happening.
# debug: To provide more detailed information such as variables in the script. For debug to work it has to be selected
# as an option in the command (-d or --debug) and the word debug occurs after the msg, eg ocmsg "var: $var" debug
ocmsg() {
  # This is to provide extra messaging if the verbose variable in pl.yml is set to y.

  if [[ "$verbose" == "normal" ]] && [[ -z "$2" ]]; then
    echo $1
  elif [[ "$verbose" == "debug" ]]; then
    echo $1
  fi
}

# This will set the correct permissions
# Presumes the following information is set:
# $user
# $folder
# $sitename_var
# $webroot
set_site_permissions() {
  if [ "$dev" = "y" ] || [ "$verbose" = "debug" ]; then
    devp="--dev"
  fi

  ocmsg "Fixing permissions: --drupal_path="$site_path/$sitename_var/$webroot" --drupal_user=$user --httpd_group=www-data $devp" debug
  sudo dfp.sh --drupal_path="$site_path/$sitename_var/$webroot" --drupal_user=$user --httpd_group=www-data $devp
}

# This will delete current site database and rebuild it
# Persumes the following information is set:
# $user
# $folder
# $sitename_var
# $webroot
rebuild_site() {
  #etc
  echo "bstep $bstep"
  if [ -z $bstep ]; then
    bstep=1
  fi
  echo "bstep $bstep"

  if [ $bstep -gt 1 ]; then
    echo "Starting from build step $step"
  fi

  echo "Create database and user if needed."

  if [ $bstep -lt 2 ]; then
    echo -e "$Purple build step 1: create the database $Color_Off"
    if [[ "$lando" == "y" ]]; then
      echo "Skip make_db since Lando come with a databse."
    else
      make_db
    fi
  fi

  if [ $bstep -lt 3 ]; then
    echo -e "$Purple build step 2: Build the drupal site $sitename_var $Color_Off"

    # drush status
    site_info

    if [[ "$lando" == "y" ]]; then
      cd $site_path/$sitename_var
      lando drush -y site-install $profile --db-url=mysql://drupal8:drupal8@database/drupal8 --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sitename_var" --sites-subdir=default
      exit 0
    else
      # drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
      cd $site_path/$sitename_var/$webroot

      #echo "drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sitename_var" --sites-subdir=default"

      drush -y site-install $profile --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sitename_var" --sites-subdir=default
    #don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.
    fi
  fi

  if [ $bstep -lt 4 ]; then
    echo -e "$Purple build step 3: set site permissions $Color_Off"
    #sudo bash ./dfp.sh --drupal_path=$folder/$webroot --drupal_user=$user #shouldn't need this, since files don't need to be changed.
    #chmod g+w -R $folder/$webroot/modules/custom
    set_site_permissions
  fi

  if [ $bstep -lt 5 ]; then
    echo -e "$Purple build step 4: install drupal console $Color_Off"

    # work out where composer.json is
    cd $site_path/$sitename_var

    if [[ ! -f composer.json ]]; then
      cd $webroot
    fi

    ocmsg "path where composer is run: $(pwd)" debug

    # This makes sure it will run. It would be better to test that there is a problem with the normal way, but this will
    # make sure it will work.
    rm composer.lock
    rm vendor -rf
    composer require drupal/console --prefer-dist --optimize-autoloader

    #    result=$(composer require drupal/console --prefer-dist --optimize-autoloader 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
    #
    #   if [ "$result" = ": 0" ]; then
    #    echo "Drupal Console installed"
    #  else
    #    # Make sure it installs
    #    ocmsg "There was a problem with the normal installation of Drupal Console, so trying another way."
    #    rm composer.lock
    #    rm vendor -rf
    #    composer require drupal/console --prefer-dist --optimize-autoloader
    #  fi

  fi

  if [ $bstep -lt 6 ]; then
    echo -e "$Purple build step 5: install themes if required $Color_Off"
    # Install any themes
    if [[ "$theme" != "" ]]; then
      echo "Install theme for $sitename_var using uri $uri and theme $theme"
      cd $site_path/$sitename_var/$webroot
      drupal --target=$uri theme:install $theme
      drush @$sitename_var config-set system.theme default $theme -y
    fi

    if [[ "$theme_admin" != "" ]]; then
      echo "Install theme for $sitename_var"
      cd $site_path/$sitename_var/$webroot
      drupal --target=$uri theme:install $theme_admin
      drush @$sitename_var config-set system.theme admin $theme_admin -y
    fi
    #drush cr #is this needed here?
    drush @$sitename_var cr
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

  if [ $bstep -lt 7 ]; then
    echo -e "$Purple build step 6: install modules $Color_Off"

    if [ "$install_modules" != "" ]; then
      echo "Install modules for $sitename_var"
      drush @$sitename_var en -y $install_modules
    fi
  fi

  #drush pm-uninstall -y oc_prod
  if [ $bstep -lt 8 ]; then
    echo -e "$Purple build step 7: set to dev or production mode $Color_Off"
    cd $site_path/$sitename_var/$webroot
    if [ "$dev" == "y" ]; then
      echo "Setting to dev mode"
      drupal site:mode dev
      drush @$sitename_var php-eval 'node_access_rebuild();'
      drush @$sitename_var en -y $dev_modules
    else

      drupal --target=$uri site:mode prod
    fi
  fi
}

#
#
backup_site() {
  #backup db.
  #use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
  cd
  # Check if site backup folder exists
  if [ ! -d "$folderpath/sitebackups" ]; then
    mkdir "$folderpath/sitebackups"
  fi

  if [ ! -d "$site_path/$sitename_var" ]; then
    echo "No site folder $sitename_var so no need to backup"
    exit
  fi

  # Check if site backup folder exists
  if [ ! -d "$folderpath/sitebackups/$sitename_var" ]; then
    mkdir "$folderpath/sitebackups/$sitename_var"
  fi

  # Check if site backup folder exists
  if [ ! -d "$folderpath/sitebackups/$site_to" ]; then
    mkdir "$folderpath/sitebackups/$site_to"
  fi

  ocmsg "cd $site_path/$sitename_var" debug
  cd "$site_path/$sitename_var"
  #this will not affect a current git present
  git init
  cd "$webroot"
  msg="${msg// /_}"
  Name=$(date +%Y%m%d\T%H%M%S-)$(git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g')-$(git rev-parse HEAD | cut -c 1-8)$msg.sql

  echo -e "\e[34mbackup db $Name\e[39m"
  # Make database smaller.
  drush cr
  # Could add more directives to make database even smaller.
  drush sql-dump --result-file="$folderpath/sitebackups/$site_to/$Name"

  #backupfiles
  Name2=${Name::-4}".tar.gz"

  echo -e "\e[34mbackup files $Name2\e[39m"
  cd $site_path
  tar -czf $folderpath/sitebackups/$site_to/$Name2 $sitename_var

}

#
# User server script to backup production database so it can be run in parallel
gitbackupdb() {
  #    drush @prod sql-dump --result-file="/home/$prod_user/proddb/prod.sql"
  #    ssh $prod_alias "cd proddb && git add . && git commit -m \"$(date +%Y%m%d\T%H%M%S-)\" && git push"
  echo -e "$Purple gitbackupdb: $prod_docroot@$prod_alias"
  ssh $prod_alias "./gitbackupdb.sh $prod_docroot  $Bname"

  #Don't need all this since git database is only going one way now
  #  echo -e "$Purple git pull"
  #  if [[ ! -d $folderpath/sitebackups/proddb ]] ; then
  ##    mkdir $folderpath/sitebackups/proddb
  #    # need to clone the database
  ##    cd $folderpath/sitebackups/proddb
  #    git clone $prod_gitdb
  #  else
  #    cd $folderpath/sitebackups/proddb
  #    ocmsg "Git pull -X theirs"
  #    git pull -X theirs
  #  fi

  echo -e "$Color_Off"
}

#
# User server script to backup production files so it can be run in parallel
gitbackupfiles() {
  echo -e "$Cyan gitbackupfiles "
  ssh $prod_alias "./gitbackupfiles.sh $prod_docroot $Bname"
  echo -e "$Color_Off"
}

#
# User server script to backup production files so it can be run in parallel
gitprodpush() {
  # Make sure ssh identity is added
  add_git_credentials
  #backup db.
  #use git:
  #https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7

  msg=${1// /_}
  # Run commands in parallel
  echo -e "$Cyan Running git pull for site and db on production $Color_Off"
  Bname=$(date +%d%b%gT%l:%M:%S%p)
  Bname=${Bname//[[:blank:]]/}
  echo "Commit name >$Bname<"
  gitbackupdb
  gitbackupfiles
  #wait
  echo "Production site and files backuped"

}

backup_prodr() {

      if [ "${site_to: -4}" = "prod" ]; then
        siteto_var_len=$(echo -n $site_to | wc -m)
        sitename_pre=${site_to:0:$(($siteto_var_len - 5))}
        ocmsg "site_to $site_to sitename_pre $sitename_pre" debug
        # Store the backup to the production folder on the dev machine.

        if [ ! -d "$folderpath/sitebackups/$sitename_pre" ]; then
          mkdir "$folderpath/sitebackups/$sitename_pre"
        fi
        if [ ! -d "$folderpath/sitebackups/$sitename_pre/prod" ]; then
          mkdir "$folderpath/sitebackups/$sitename_pre/prod"
        fi
        site_to="$sitename_pre/prod"
      else

        # Check if site backup folder exists
        if [ ! -d "$folderpath/sitebackups/$sitename_var" ]; then
          mkdir "$folderpath/sitebackups/$sitename_var"
        fi
        if [ ! -d "$folderpath/sitebackups/$sitename_var/prod" ]; then
          mkdir "$folderpath/sitebackups/$sitename_var/prod"
        fi
        site_to="$sitename_var/prod"
      fi
      msg="${msg// /_}"
      ocmsg "Backing up production site $sitename_var on server with alias $prod_alias with message $msg and onto dev at $folderpath/sitebackups/$site_to" debug

      #site_info
      #Name="$folderpath/sitebackups/prod/prod$(date +%Y%m%d\T%H%M%S-)$msg"

    ssh $prod_alias -t "./backupprod.sh $prod_docroot $msg"

      # Get the latest backup name
      Prodsql=$(ssh $prod_alias -t "./getlatestbackup.sh $prod_uri")
      # todo this next line is needed for some reason don't know why.
      Prodsql=${Prodsql::-1}
      ocmsg "Prodsql >$Prodsql<" debug
      Name="${Prodsql::-4}.tar.gz"
      ocmsg "sql: $Prodsql tar: $Name" debug
      Namesql="$folderpath/sitebackups/$site_to/$Prodsql"
      ocmsg "backup name /home/$prod_user/$prod_uri/$Prodsql" debug
      cp "$prod_alias:/home/$prod_user/$prod_uri/$Prodsql" "$Namesql"
}

#
#
backup_prod() {

  # Make sure ssh identity is added

  #backup db.
  #use git:
  #https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
  ocmsg "Backing up site $sitename_var with alias $prod_alias and message $msg to $site_to" debug
  if [[ "$sitename_var" == "$site_to" ]]; then
    # Backup production on production
    echo "Backing up production site $sitename_var on server only."
    ssh $prod_alias -t "./backupprod.sh $prod_docroot $msg"

  else

    if [[ "$prod_method" == "git" ]]; then
      if [[ ! "$prod_gitdb" == "" ]]; then
        echo "proddb $prod_gitdb"
        add_git_credentials
        gitprodpush
      else
        echo "Git method for prod backup chosen, but no gitdb set. Exiting"
        exit 1
        #Now move the db and files down to local
        #    scp "$prod_alias:proddb/prod.sql" "$folderpath/sitebackups/prod/$Bname.sql"
        #    wget https://github.com/rjzaar/ocorg/archive/master.tar.gz -O "$folderpath/sitebackups/prod/$Bname.tar.gz"

        #    # Use git to put the files in the correct place
        #      rm -rf "$site_path/$sitename_var"
        #      cd $site_path
        #      git clone $prod_gitrepo $sitename_var
        #    # now tar it.
        #    tar --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.local.php' --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.php' -zcf "$folderpath/sitebackups/prod/$bname.tar.gz" "$site_path/$sitename_var"
      fi
    else

      if [ "${site_to: -4}" = "prod" ]; then
        siteto_var_len=$(echo -n $site_to | wc -m)
        sitename_pre=${site_to:0:$(($siteto_var_len - 5))}
        ocmsg "site_to $site_to sitename_pre $sitename_pre" debug
        # Store the backup to the production folder on the dev machine.

        if [ ! -d "$folderpath/sitebackups/$sitename_pre" ]; then
          mkdir "$folderpath/sitebackups/$sitename_pre"
        fi
        if [ ! -d "$folderpath/sitebackups/$sitename_pre/prod" ]; then
          mkdir "$folderpath/sitebackups/$sitename_pre/prod"
        fi
        site_to="$sitename_pre/prod"
      else

        # Check if site backup folder exists
        if [ ! -d "$folderpath/sitebackups/$sitename_var" ]; then
          mkdir "$folderpath/sitebackups/$sitename_var"
        fi
        if [ ! -d "$folderpath/sitebackups/$sitename_var/prod" ]; then
          mkdir "$folderpath/sitebackups/$sitename_var/prod"
        fi
        site_to="$sitename_var/prod"
      fi
      msg="${msg// /_}"
      ocmsg "Backing up production site $sitename_var on server with alias $prod_alias with message $msg and onto dev at $folderpath/sitebackups/$site_to" debug

      #site_info
      #Name="$folderpath/sitebackups/prod/prod$(date +%Y%m%d\T%H%M%S-)$msg"

      #rz#ssh $prod_alias -t "./backupprod.sh $prod_docroot $msg"

      # Get the latest backup name
      Prodsql=$(ssh $prod_alias -t "./getlatestbackup.sh $prod_uri")
      # todo this next line is needed for some reason don't know why.
      Prodsql=${Prodsql::-1}
      ocmsg "Prodsql >$Prodsql<" debug
      Name="${Prodsql::-4}.tar.gz"
      ocmsg "sql: $Prodsql tar: $Name" debug
      Namesql="$folderpath/sitebackups/$site_to/$Prodsql"
      ocmsg "backup name /home/$prod_user/$prod_uri/$Prodsql" debug
      #rz#scp "$prod_alias:/home/$prod_user/$prod_uri/$Prodsql" "$Namesql"
      echo -e "\e[34mbackup files $Name\e[39m"
      if [[ "$pdmethod" == "tar" ]] ; then
        scp "$prod_alias:/home/$prod_user/$prod_uri/$Name" "$folderpath/sitebackups/$site_to/$Name"
      else
        PD=$prod_docroot
            P_NODUPSLASH="${PD//\/*(\/)/\/}"
            P_ENDNOSLASH="${P_NODUPSLASH%%/}"
            prod_folder="${P_ENDNOSLASH%/*}/"
        ocmsg "Prod folder: $prod_folder"
        ocmsg "using rsync to bring down the production site: $prod_alias:$prod_folder to $site_path/$rsync_var/"


        ## todo could add code so it deals with whatever the webroot is.
        rsync -rav --delete --exclude 'docroot/sites/default/settings.*' \
                    --exclude 'docroot/sites/default/services.yml' \
                    --exclude 'docroot/sites/default/files/' \
                    --exclude 'web/sites/default/settings.*' \
                    --exclude 'web/sites/default/services.yml' \
                    --exclude 'web/sites/default/files/' \
                    --exclude 'html/sites/default/settings.*' \
                    --exclude 'html/sites/default/services.yml' \
                    --exclude 'html/sites/default/files/' \
                    --exclude '.git/' \
                    --exclude '.gitignore' \
                    --exclude 'private/' \
                    --exclude '*/node_modules/' \
                    --exclude 'node_modules/' \
                    --exclude 'dev/' \
                    "$prod_alias:$prod_folder"  "$site_path/$rsync_var/" # > rsyncerrlog.txt
        # &> rsyncerrlog.txt
        if [ "$verbose" == "debug"  ] ; then
          if grep -q 'rsync' rsyncerrlog.txt; then
            echo "Error Message from rsync"
        cat rsyncerrlog.txt | grep "rsync"
        fi
          fi
        #rm rsyncerrlog.txt
        ocmsg "Rsync Finished." debug

        fi
    fi
  fi
}

#
# This will copy the production site to the test site.
copy_prod_test() {
  echo "Copying the production site to the test site."
  ssh $prod_alias -t "./copy_prod_test.sh $prod_docroot"
}
#
#
backup_db() {
  echo -e "$Green backing up $sitename_var $Color_Off"

  # Check if site backup folder exists
  if [ ! -d "$folderpath/sitebackups" ]; then
    ocmsg "Creating sitebackups folder" debug
    mkdir "$folderpath/sitebackups"
  fi

  #backup db.
  #use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
  # Check if site backup folder exists
  if [ ! -d "$folderpath/sitebackups/$sitename_var" ]; then
    ocmsg "Creating backup folder for $sitename_var" debug
    mkdir "$folderpath/sitebackups/$sitename_var"
  fi

  cd
  cd "$site_path/$sitename_var"

  #this will not affect a current git present
  ocmsg "Initialising git repo in site $sitename_var"
  git init
  cd "$webroot"
  msg=${1// /_}
  Name=$(date +%Y%m%d\T%H%M%S-)$(git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g')-$(git rev-parse HEAD | cut -c 1-8)$msg.sql
  echo -e "\e[34mbackup db $Name\e[39m"
  ocmsg "Putting site $sitename_var into maintenance mode." debug
  drush @$sitename_var sset system.maintenance_mode TRUE
  ocmsg "Dumping the database of $sitename_var" debug
  drush @$sitename_var sql-dump --result-file="$folderpath/sitebackups/$sitename_var/$Name"
  ocmsg "Taking out site $sitename_var of maintenance mode." debug
  drush @$sitename_var sset system.maintenance_mode FALSE
  ocmsg "Database $sitename_var has been backed up." debug
}

#
# Make the database for the site
# pltest is set by the -t option in install to indicate a testing environment such as travis which requires
# unique mysql permissions for some reason.
make_db() {
  echo "Create database $db and user $dbuser if needed. Using $folderpath/mysql.cnf"

  #check which password works.
  plcred="--defaults-extra-file=$folderpath/mysql.cnf"
  result=$(
    mysql $plcred -e "use mysql;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )
  echo "result1: >$result<"
  if [[ "$result" != ": 0" ]]; then
    #plcred="--password=\"\""
    plcred=""
    result=$(
      mysql $plcred -e "use mysql;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    echo "result2: >$result<"
    if [[ "$result" != ": 0" ]]; then
      plcred="--password=\"\""
      result=$(
        mysql $plcred -e "use mysql;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
        echo ": ${PIPESTATUS[0]}"
      )
      echo "result3: >$result<"
      if [[ "$result" != ": 0" ]]; then

        echo "mysql password is not blank nor is it correct in mysql.cnf"
      fi
    fi
  fi

  echo "plcred: $plcred"

  result=$(
    mysql $plcred -e "use $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )

  if [ "$result" != ": 0" ]; then
    echo "The database $db does not exist. I will try to create it."
    result=$(
      mysql $plcred -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [[ "$result" != ": 0" ]]; then
      # This script actually just tries to create the user since the database will be created later anyway.
      echo "Unable to create the database $db. Check the mysql root credentials in mysql.cnf"
      exit 1
    else
      echo "Database $db created."
    fi
  else
    echo "Database $db exists so I will drop it."
    result=$(
      mysql $plcred -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [ "$result" = ": 0" ]; then
      echo "Database $db dropped"
    else
      echo "Could not drop database $db: exiting"
      exit 1
    fi
    result=$(
      mysql $plcred -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
      2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [ "$result" = ": 0" ]; then
      echo "Created database $db using user root"
    else
      echo "Could not create database $db using user root, exiting"
      exit 1
    fi
  fi

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
    mysql $plcred -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '$dbuser'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2
    echo ": ${PIPESTATUS[0]}"
  )
  if [ "$result" = ": 0" ]; then
    echo "Granted user $dbuser permissions on $db"
  else
    result=$(
      mysql $plcred -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '$dbuser'@'localhost';" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [ "$result" = ": 0" ]; then
      echo "Granted user $dbuser permissions on $db"
    else

      echo "Could not grant user $dbuser permissions on $db"
    fi
  fi
}

#
# presumes that the correct information is already set:
# $Name backup sql file
# $db
# $dbuser
# $dbpass
restore_db() {
  echo "restore db start"

  make_db

  if [[ "${bk: -4}" == "prod" ]] && [[ "$prod_method" == "git" ]]; then
    # todo this needs to be updated
    echo "restore_db prod git needs to be updated. Exiting"
    exit
    echo -e "\e[34mrestore $db database using git production\e[39m"
    result=$(
      mysql --defaults-extra-file="$folderpath/mysql.cnf" $db <"$folderpath/sitebackups/$sitename_var/prod/proddb/prod.sql" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )

  elif [[ "${bk: -4}" == "prod" ]] && [[ "$prod_method" == "tar" ]]; then
    result=$(
      mysql --defaults-extra-file="$folderpath/mysql.cnf" $db <"$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )

  else
    echo -e "\e[34mrestore $db database using $folderpath/sitebackups/$bk/$Name\e[39m"
    result=$(
      mysql --defaults-extra-file="$folderpath/mysql.cnf" $db <"$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
  fi

  if [ "$result" = ": 0" ]; then
    echo "Backup database $Name imported into database $db using root"
  else
    echo "Could not import $Name into database $db using root, exiting"
    exit 1
  fi

  drush @$sitename_var cr 2>/dev/null | grep -v '+' | cut -d' ' -f2
  if [[ "${PIPESTATUS[0]}" == "1" ]]; then
    # If there is an error, it is most likely due to a drush issue so reinstall drush.
    echo "There is a problem with drush. Reinstalling drush."
    rm "$site_path/$sitename_var/vendor/drush" -rf

    # Make sure example.gitignore is present.
    if [[ ! -f "$site_path/$sitename_var/$docroot/core/assets/scaffold/files/example.gitignore" ]]; then
      wget https://raw.githubusercontent.com/drupal/drupal/9.2.x/example.gitignore -P "$site_path/$sitename_var/$docroot/core/assets/scaffold/files/"
    fi

    cd "$site_path/$sitename_var/"
    composer install --no-dev
    sudo chown :www-data vendor/drush -R
    echo "Drush reinstalled."
  fi
  echo "Turn off maintenance mode."
  drush @$sitename_var sset system.maintenance_mode FALSE
  echo "Turn off read only mode if present"
  result_rom=$(drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; })
  if [[ ! "$result_rom" == "" ]]; then
    drush @$sitename_var cset readonlymode.settings enabled 0 -y
  fi
}

#
#
test_site() {
  echo $sitename_var, $db, $dbuser, $dbpass
}

#
#
db_defaults() {
  # Database defaults
  echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
  if [ -z ${db+x} ]; then
    db="$sitename_var$folder"
  fi

  if [ -z ${dbuser+x} ]; then
    dbuser=$db
  fi

  if [ -z ${dbpass+x} ]; then
    dbpass=$dbuser
  fi
  echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
}

#
#
site_info() {

  #!!!! add code to handle info type.
  echo "Source  = $project"
  echo "Project folder = $folder"
  echo "Site folder = $sitename_var"
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
  echo "prod_user" = $prod_user
  echo "prod_alias" = $prod_alias
  echo "prod_docroot" = $prod_docroot
  echo "prod_method" = $prod_method
  echo "prod_uri" = $prod_uri
  echo "prod_gitdb" = $prod_gitdb
  echo "prod_gitkey" = $prod_gitkey
  echo "prod_gitrepo" = $prod_gitrepo
  echo "prod_test_uri" = $prod_test_uri
  echo "prod_test_docroot" = $prod_test_docroot
  echo "prod_reinstall_modules" = $prod_reinstall_modules
}

#
#
copy_site_files() {
  from=$1
  sitename_var=$2
  echo "From $from to $sitename_var"
  tosite=$sitename_var
  #We need to work out where each site is.
  import_site_config $from
  from_sp=$site_path
  import_site_config $tosite
  to_sp=$site_path

  if [ -d $to_sp/$sitename_var ]; then
    sudo chown $user:www-data $to_sp/$tosite -R
    chmod +w $to_sp/$tosite -R
    rm -rf $to_sp/$tosite
  fi
  echo "Move all files from $from to $tosite"
  cp -rf "$from_sp/$from" "$to_sp/$tosite"
}

#
#
copy_site_folder() {
  from=$1
  sitename_var=$2
  echo "Copy site folder from $from to $sitename_var"

  if [ -d $site_path/$sitename_var/$webroot/sites ]; then
    chown $user:www-data $site_path/$sitename_var/$webroot/sites -R
    chmod +w $site_path/$sitename_var/$webroot/sites -R
    rm -rf $site_path/$sitename_var/$webroot/sites
  fi

  echo -e "\e[34mcopy private files from $from\e[39m"
  rm -rf $site_path/$sitename_var/private
  cp -rf "$site_path/$from/private" "$site_path/$sitename_var/private"
  cp -rf "$site_path/$from/$webroot/sites" "$site_path/$sitename_var/$webroot/sites"
}

#
#
update_locations() {
  # This will update the key directory locations set by the environment and pl.yml
  # It presumes that _inc.sh has already been run and parse_pl_yml has been run.
ocmsg "pwd $(pwd) directory $dirname dir+ $(dirname $0)  0 $0" debug
cd
#  DIRECTORY=$(cd $(dirname $0) && pwd)
#  ocmsg "Directory $DIRECTORY"
  echo "pwd $(pwd)"
 cd $(dirname $0)
#  echo "Directory: $DIRECTORY pwd: $(pwd)"
  IFS="/" read -ra PARTS <<<"$(pwd)"
  user=$USER
project=${PARTS[3]}
  for ((i = 4 ; i < ${#PARTS[@]}-1 ; i++)); do
    $project=$project +"/"+ ${PARTS[i]}
  done
  ocmsg "user: $user  project: $project" debug
  store_project=$project
  # Check correct user name
  if [ ! -d "/home/$user" ]; then
    echo "User name in pl.yml $user does not match the current user's home directory name. Please fix pl.yml."
    exit 1
  fi

  # Create the pl_var file if it doesn't exist yet.
  if [ ! -f "/home/$user/$project/pl_var.sh" ]; then
    cat >/home/$user/$project/pl_var.sh <<EOL
#!/bin/bash
# Do not modify anything here. It is automatically created and updated as needed. Change settings in pl.yml or mysql.cnf



EOL
  fi

  script_root="/home/$user/$project/scripts"
  echo "script_root: $script_root"
  # This will collect www_path
  parse_pl_yml

  project=$store_project
  echo "Project: $project"
  echo "www_path: $www_path"
  plhome="/home/$user/$project"
  bin_home="/home/$user/$project/bin"
  ocmsg "bin_home: $bin_home plhome: $plhome" debug
  ocmsg ".bashrc: before exports::" debug
  if [[ "$verbose" == "debug" ]]; then
    cd
    cat .bashrc
  fi
  sed -i "3s#.*#ocroot=\"/home/$user/$project\"#" "$plhome/pl_var.sh"
  sed -i "2s#.*#ocroot=\"/home/$user/$project\"#" "$bin_home/sudoeuri.sh"
  # Add escape backslashes to www_path and store it.
  wwwp="${www_path////\\/}"
  sed -i "4s#.*#ocwroot=\"$wwwp\"#" "$plhome/pl_var.sh"
  sed -i "3s#.*#ocwroot=\"$wwwp\"#" "$bin_home/sudoeuri.sh"
  # Add escape backslashes to script_root and store it.
  sr="${script_root////\\/}"
  sed -i "5s#.*#script_root="$sr"#" "$plhome/pl_var.sh"
  sed -i "4s#.*#script_root="$sr"#" "$bin_home/sudoeuri.sh"

  # todo: If locations have been changed, then old paths need to be removed
  # todo: sudoeuri.sh will need to be moved again to its proper location
  EXPORT_PATH="export PATH=\"\$PATH:$bin_home\""
  SOURCE_PATH=". $bin_home/plextras.sh"
  ocmsg "export_path: $EXPORT_PATH SOURCE_PATH: $SOURCE_PATH" debug
  cd
  if [[ -f .bashrc ]]; then
    ocmsg "exporting path to bashrc" debug
    echo "$EXPORT_PATH" >>.bashrc
    source .bashrc
  fi
  if [[ -f .bashrc ]]; then
    ocmsg "exporting plextras to bashrc" debug
    echo "$SOURCE_PATH" >>.bashrc
    source .bashrc
  fi

  # ZSH Support
  if [[ -f ~/.zshrc ]]; then
    if [[ $(grep "$EXPORT_PATH" ~/.zshrc) ]]; then
      ocmsg "exporting path to zshrc" debug
      echo "$EXPORT_PATH" >>~/.zshrc
      source .zshrc
    fi
    if [[ $(grep "$SOURCE_PATH" ~/.zshrc) ]]; then
      ocmsg "exporting plextras to zshrc" debug
      echo "$SOURCE_PATH" >>~/.zshrc
      source .zshrc
    fi
  fi

  ocmsg ".bashrc: after exports::" debug
  if [[ "$verbose" == "debug" ]]; then
    cd
    cat .bashrc
  fi

}

#
# Add git credentials
add_git_credentials() {
  ocmsg "Add git credentials $user_home/.ssh/$github_key"
  eval $(ssh-agent -s)
  if [[ "$verbose" == "debug" ]]; then
    ssh-add $user_home/.ssh/$github_key
  else
    ssh-add $user_home/.ssh/$github_key >/dev/null
  fi
  # Could remove all messages including error, but it is important for that kind of error to turn up in normal operation.
  # so don't do: ssh-add ~/.ssh/$github_key > /dev/null 2>&1
}

#
# Run composer command for particular site. Since composer.json could be in different locations, this command is needed.
plcomposer() {
  cd $site_path/$sitename_var
  # Need to check if composer is installed.
  echo "Trying composer $* at $(pwd)"
  if [ -f composer.json ]; then
    composer $*
  else
    cd $webroot
    if [ -f composer.json ]; then
      composer $*
    else
      echo "Can't find composer.json in $site_path/$sitename_var or $webroot. Exiting. "
      exit 1
    fi
  fi

}

# Run updates for a drupal site. Can be external.
runupdates() {

  if [[ "${sitename_var:0:4}" == "prod" || "${sitename_var:0:4}" == "test" ]]; then
    echo "Runupdates  on $prod_alias  on site $sitename_var"
    # todo work out why these next three lines are needed.
    #    eval $(ssh-agent -s)
    #    echo "Adding: $(dirname $(dirname $script_root))/.ssh/$prod_gitkey"
    #    ssh-add "$(dirname $(dirname $script_root))/.ssh/$prod_gitkey"
    # presume you don't need toProduction site fix site settings for production sites.
    if [[ "${sitename_var:0:4}" == "test" ]]; then
      # This script just runs the composer install --no-dev and fixes site permissions.
      echo "Running updatetest.sh"
      ssh -t $prod_alias "./updatetest.sh $prod_test_docroot $prod_reinstall_modules"
    else
      #Now run the rest of the update process.
      echo "Running updateprod.sh"
      ssh -t $prod_alias "./updateprod.sh $prod_docroot $prod_reinstall_modules"
      # The updateprod script does it all.
    fi
  else
    echo "Runupdates  on site $sitename_var"
    ocmsg "Path: $site_path/$sitename_var" debug
    cd $site_path/$sitename_var
    # composer install
    echo -e "\e[34m composer install \e[39m"
    # Looks like it is best to remove composer.lock so getting the latest according to composer.json
    if [[ -f $site_path/$sitename_var/composer.lock ]]; then
      rm $site_path/$sitename_var/composer.lock
    fi
    #rm $site_path/$sitename_var/vendor -rf
    composer install --no-dev # composer install needs phing. so remove phing!
    set_site_permissions
    fix_site_settings
    cd
    echo -e "\e[34m update database for $sitename_var\e[39m"
    drush @$sitename_var updb -y
    #echo -e "\e[34m fra\e[39m"
    #drush @$sitename_var fra -y
    echo -e "\e[34m import config\e[39m"
    if [[ "$reinstall_modules" != "" ]]; then
      drush @$sitename_var pm-uninstall $reinstall_modules -y
    #  drush @$sitename_var en $reinstall_modules -y
    fi
    if [[ "$force" == "true" ]]; then
      # Collect the error from the import.
      import_result="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
      # Process the result
      echo "cim result $import_result result"

      import_result1="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
      import_result2="$(drush @$sitename_var cim -y --pipe 2>&1 >/dev/null || true)"
    #if error then delete the erroneous config files.
    #Still needs to be written #####

    else

      echo "Run CMI import"
      # see for the reason for this structure: https://www.bounteous.com/insights/2020/03/11/automate-drupal-deployments/
      drush @$sitename_var cim -y || drush @$sitename_var cim -y #--source=../cmi
      drush @$sitename_var cim -y
    fi

    if [[ "$reinstall_modules" != "" ]]; then
      echo "reinstalling modules"
      #  drush @$sitename_var pm-uninstall $reinstall_modules -y
      drush @$sitename_var en $reinstall_modules -y
    fi
    # deal with bad config.
    echo "fixing site permissions"
    if [[ "${sitename_var:0:4}" == "prod" || "${sitename_var:0:4}" == "test" ]]; then
      if [[ "$sitename_var" == "test" ]]; then
        ssh -t $prod_alias "sudo ./dfp.sh --drupal_user=$prod_user --drupal_path=$prod_test_docroot"
      else
        ssh -t $prod_alias "sudo ./dfp.sh --drupal_user=$prod_user --drupal_path=$prod_docroot"
      fi
      # Take out of maintenance or readonly mode
      echo "Checking for readonly mode"
      readonly_en=$(ssh -t cathnet "cd $prod_test_docroot && drush pm-list --pipe --type=module --status=enabled --no-core | { grep 'readonlymode' || true; }")
      if [ ! "$readonly_en" == "" ]; then
        ssh -t cathnet "cd $prod_test_docroot && drush cset readonlymode.settings enabled 0 -y"
      else
        # otherwise put into maintenance mode
        ssh -t cathnet "cd $prod_test_docroot && drush sset maintenance_mode 0"
      fi

    else
      set_site_permissions
      echo -e "\e[34m make sure out of maintenance and readonly mode\e[39m"
      drush @$sitename_var sset system.maintenance_mode FALSE
      drush @$sitename_var cset readonlymode.settings enabled 0 -y

    fi

    echo "Running drush cr"
    drush @$sitename_var cr

  fi

}

# Update pleasy readme with the latest function explanations.
makereadme() {

  cd
  cd pleasy
  if [ ! -f README.md ]; then
    echo "Need a README.md to start with!"
    exit 1
  fi

  cp README.md README_TEMP.md
  # Strip out old functions
  fline=$(grep -n '# FUNCTION LIST' README_TEMP.md)
  ocmsg "fline ${fline:0:3}" debug
  fline=${fline:0:3}
  fline=$((fline + 1))
  ocmsg "fline $fline" debug
  sed -i "$fline,2000d" ./README_TEMP.md

  if [ -d $script_root ]; then
    cd "$script_root"
  else
    echo 'ERROR: Either pleasy $script_root variable does not exist, or the value is set incorrectly.'
    exit 1
  fi

  (
    documented_scripts=$(grep -l --directories=skip --exclude={_inc,makereadme*}.sh '^args=$(getopt' *.sh)
    undocumented_scripts=$(grep -L --directories=skip --exclude={_inc,makereadme*}.sh '^args=$(getopt' *.sh)
    working_dir=$(pwd)

    for command in $documented_scripts; do
      help_documentation=$("$working_dir/$command" --help | tail -n +2)

      echo $help_documentation | grep -q '^Usage:' &&
        sanitised_documentation=$help_documentation ||
        sanitised_documentation=$(
          cat <<HEREDOC
--**BROKEN DOCUMENTATION**--
$help_documentation
--**BROKEN DOCUMENTATION**--
HEREDOC
        )

      getstatus=$("$working_dir/$command" --help)
      case "$?" in
      0 | 1)
        status="❓"
        ;;
      2)
        status="👷" # works but not tested with Travis
        ;;
      3)
        status="☑" # works and passing Travis
        ;;
      *)
        status="❓"
        ;;
      esac

      cat <<HEREDOC
<details>

**<summary>${command%%.sh}: $("$working_dir/$command" --help | head -n 1) $status </summary>**
$sanitised_documentation

</details>

HEREDOC
    done

    for command in $undocumented_scripts; do
      cat <<HEREDOC
<details>

**<summary>${command%%.sh}:  ❓ </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

HEREDOC
    done
  ) >>../README_TEMP.md ||
    {
      echo "Failed to write to copied template file! aborting"
      rm ../README_TEMP.md
      exit 1
    }

  mv ../README_TEMP.md ../README.md
  echo "Functions and definitions have been generated"
}
