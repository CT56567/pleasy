#!/bin/bash

# Get the helper functions etc.
. $script_root/_inc.sh;

#. $script_root/lib/common.inc.sh;
#. $script_root/lib/db.inc.sh;
#. $script_root/scripts/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to install a variety of drupal flavours particularly opencourse, but just the file system. No database.
This will use opencourse-project as a wrapper. It is presumed you have already cloned opencourse-project.
You just need to specify the site name as a single argument.
All the settings for that site are in pl.yml
If no site name is given then the default site is created.

HELP
exit 0
}

#auto="y"
#folder=$(basename $(dirname $script_root))
#webroot="docroot" # or could be web or html
#project="rjzaar/opencourse:8.7.x-dev"
## For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
## there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and
#sitename_var="dev"
#profile="varbase"
#dev="y"

parse_pl_yml

#Import pl.yml settings
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

if [ "$#" = 0 ]
then
sitename_var="default"
else
# Check to see if recipe is present
# Get the sitename
sitename_var=$1
echo "Looking for recipe $sitename_var"
if [[ $recipes != *"$sitename_var"* ]]
then
echo "No recipe for $sitename_var! Current recipes include $recipes. Please add a recipe to pl.yml for $sitename_var"
exit 1
fi
fi

# Check for yes
if [ "$#" = 2 ] ; then yes="y" ; fi

import_site_config $sitename_var

#db_defaults

echo "Installing $sitename_var"
site_info

# Check to see if folder already exits.
if [ -d "$site_path/$sitename_var" ]; then
    if [ ! "$#" = 2 ]
    then
    read -p "$sitename_var exists. If you proceed, $sitename_var will first be deleted. Do you want to proceed?(Y/n)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    fi
    #first change permissions on sites/default
    result=$(chown $user:www-data $site_path/$sitename_var -R 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
    if [ "$result" = ": 0" ]; then echo "Changed ownership of $sitename_var to $user:www-data"
    else echo "Had errors changing ownership of $sitename_var to $user:www-data so will need to use sudo"
    sudo chown $user:www-data $site_path/$sitename_var -R
    fi
    chmod 770 $site_path/$sitename_var/$webroot/sites/default -R
    rm -rf "$site_path/$sitename_var"
fi

if [ "$install_method" == "git" ]
then
  echo "Adding git credentials"
  ssh-add /home/$user/.ssh/$github_key
  echo "Cloning $project"
  git clone $project $site_path/$sitename_var

  if [ "$git_upstream" != "" ]
  then
    cd $site_path/$sitename_var
    echo "$sitename_var has upstream git so adding $git_upstream"
    git remote add upstream $git_upstream
  fi

elif [ "$install_method" == "composer" ]
  then
  if [ "$dev" = "y" ]
  then
    echo "Setting composer install to dev."
    devs="--stability dev"
  else
    devs=""
  fi

  echo "Run composer create project: $project"
  composer create-project $project $sitename_var $devs --no-interaction
elif [ "$install_method" == "file" ]
  then
  if [ ! -d "$folderpath/downloads" ]
  then
    mkdir "$folderpath/downloads"
  fi
  cd "$folderpath/downloads"
  Name="$sitename_var.tar.gz"
  wget -O $Name $project
  tar -xf $Name -C "$site_path/$sitename_var"
else
    echo "No install method specified. You need to at least edit the default recipe in pl.yml and specify \"install_method\"."
    exit 1
fi


cd $site_path/$sitename_var

composer install

fix_site_settings

echo "Create private files directory"
if [ ! -d $private ]; then
  mkdir $private
fi
chmod 770 $private

echo "Create cmi files directory"
if [ ! -d "$site_path/$sitename_var/cmi" ]; then
  mkdir "$site_path/$sitename_var/cmi"
fi
chmod 770 "$site_path/$sitename_var/cmi"

set_site_permissions

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
echo

