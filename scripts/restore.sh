#!/bin/bash

SECONDS=0
verbose="none"

# Help menu
print_help() {
  cat <<-HELP
Restore a particular site's files and database from backup
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.
If the [FROM] site is prod, and the production method is git, git will be used to restore production

OPTIONS
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -s --step=[INT]         Restart at the step specified.
  -f --first              Use the latest backup
  -y --yes                Auto delete current content

Examples:
pl restore d9
pl restore d9 stg_d9 -fy
pl restore -h
pl restore d9 -d
pl restore d9_prod stg_d9
HELP
}

args=$(getopt -a -o hds:fyo -l help,debug,first,yes,open --name "$scriptname" -- "$@")
# echo "$args"

# Check number of arguments
# If no arguments given, prompt user for arguments
if [ "$#" = 0 ]; then
  print_help
  exit 0
fi

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 3 # pass
    ;;
  -d | --debug)
    verbose="debug"
    echo "debug mode"
    shift
    ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift
    ;;
  -f | --first)
    flag_first=1
    shift
    ;;
  -y | --yes)
    flag_yes=1
    shift
    ;;
  -o | --open)
    flag_open=1
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done

parse_pl_yml

if [[ $1 == "restore" ]] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 1
elif [ -z "$2" ]; then
  sitename_var=$1
  site_from=$1
else
  sitename_var=$2
  site_from=$1
fi
ocmsg "sitename_var $sitename_var site_from $site_from" debug
import_site_config $sitename_var

stage=""
if [ "${sitename_var:0:3}" = "stg" ]; then
  # set up stg
  sitename_var=${sitename_var:4}
  stage="stg_"
fi

bk=$site_from
#if [ "${site_from: -4}" = "prod" ]; then
#  # set up stg
##  site_from=${site_from:5}
#  bk="prod"
#
#fi
#  ocmsg "site_from $site_from shortened ${site_from: -4} bk $bk" debug
echo "Restoring site $site_from to $stage$sitename_var"
if [[ "$step" -gt 1 ]]; then
  echo "Starting from step $step"
fi
#if [[ "$bk" == prod ]] && [[ ! "$prod_method" == "git" ]]; then
#  echo "Sorry not able to handle restoring prod unless it is method git."
#  exit 0
#fi

if [[ "$step" -lt 2 ]]; then

  # Prompt to choose which database to backup, 1 will be the latest.
  # Could be a better way to go: https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt

  if [[ "$bk" == "prod" ]] && [[ "$prod_method" == "git" ]] && [[ "$sitename_var" == "prod" ]]; then
    # todo This needs to be fixed.
    echo "The code for restoring production using git needs work. Exiting"
    exit 1
    echo "Restoring production site from last git push"
    ssh $prod_alias -t "./restoreprod.sh $prod_docroot $prod_gitrepo"
    # The script does it all. No need for anything else.
    exit 0
  elif [[ "$bk" == "prod" ]] && [[ "$prod_method" == "git" ]]; then
    # todo This needs to be fixed.
    echo "The code for restoring production using git needs work. Exiting"
    exit 1
    echo "Restoring production site to site: $stage$sitename_var using git"
    # First get the database
    #scp "$prod_alias:proddb/prod.sql" "$folderpath/sitebackups/prod/$Bname.sql"
    #cp "$folderpath/sitebackups/prod/$Bname.sql" "$folderpath/sitebackups/proddb/prod.sql" -rf
    if [[ ! -d "$folderpath/sitebackups/$sitename_var" ]]; then
      mkdir "$folderpath/sitebackups/$sitename_var"
    fi

    # Check if database is already present
    if [[ -f "$folderpath/sitebackups/$sitename_var/proddb/prod.sql" ]]; then
      if [[ "$(git config --get remote.origin.url)" == "$prod_gitdb" ]]; then

        ocmsg "Pull the database down to proddb." debug
        cd $folderpath/sitebackups/$sitename_var/proddb/
        git fetch --all
        #git checkout -b backup-master
        git reset --hard origin/master
      else
        removedb="yes"
      fi
    else
      removedb="yes"
    fi
    if [[ "$removedb" == "yes" ]]; then
      # Check if proddb exits
      if [[ -d "$folderpath/sitebackups/$sitename_var/proddb/" ]]; then
        echo "removing proddb"
        rm "$folderpath/sitebackups/proddb" -rf
      fi
      echo "Cloning $prod_gitdb into $folderpath/sitebackups/$sitename_var/proddb/"
      git clone $prod_gitdb "$folderpath/sitebackups/$sitename_var/proddb/"
      echo "Git clone complete."
    fi

    echo "Now get the site files."

    if [[ -d "$site_path/$stage$sitename_var" ]]; then
      # Check that if the site exists, that it has the prod repo. Then only need to pull it!
      ocmsg "The site: $stage$sitename_var already exits. Now check if it is has the prod repo." debug
      cd "$site_path/$stage$sitename_var"
      ocmsg "Local: $(git config --get remote.origin.url) Remote: $prod_gitrepo"
      if [[ "$(git config --get remote.origin.url)" == "$prod_gitrepo" ]]; then
        # Nice and simple!
        ocmsg "Pull the files down." debug
        git fetch --all
        #git checkout -b backup-master
        git reset --hard origin/master
      else
        ocmsg "Removing old $sitename_var site and cloning the files into $sitename_var" debug
        # Set up the prod repo in the desired site location after deleting what is already there.
        rm -rf "$site_path/$stage$sitename_var"
        cd $site_path
        git clone $prod_gitrepo $stage$sitename_var
      fi
    else
      # clone the repo
      ocmsg "Cloning the files into $stage$sitename_var" debug
      echo "Cloning the files into $stage$sitename_var"
      cd $site_path
      git clone $prod_gitrepo $stage$sitename_var
    fi

    # now tar it so it is backed up for future use while we are at it.
    #tar --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.local.php' --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.php' -zcf "$folderpath/sitebackups/prod/$bname.tar.gz" "$site_path/$sitename_var"
    echo "Fix site settings"
    # messy
    store_sitename_var=$sitename_var
    sitename_var="$stage$sitename_var"
    fix_site_settings

    echo "Set site permissions"
    set_site_permissions $sitename_var

    #restore db
    db_defaults
    echo -e "$Cyan Restore the database $Color_Off"
    restore_db
    echo -e "$Cyan Files and database have been restored $Color_Off"

    # messy but put the value back.
    sitename_var=$store_sitename_var
    exit
  elif [[ "$bk" == "prod" ]] && [[ "$prod_method" == "tar" ]]; then
    # todo This is kind of defunct since the else below covers d9_prod scenario which this is
    # dealing with. But this could replace the backup of prod itself....
    echo "restore prod tar needs work. Exiting."
    exit
    echo "Restoring production site to site: $stage$sitename_var using tar method"

    echo "Now get the site files."

    if [[ -d "$site_path/$stage$sitename_var" ]]; then
      rm "$site_path/$stage$sitename_var" -rf
      mkdir "$site_path/$stage$sitename_var"
    else
      mkdir "$site_path/$stage$sitename_var"
    fi
    if [[ "$Namef" == "" ]]; then
      #get the latest file
      cd $folderpath/sitebackups/$site_from/prod/
      options=($(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t))
      Name=${options[0]:2}
      tar -zxf "$folderpath/sitebackups/$site_from/prod/${Name::-4}.tar.gz" -C "$site_path/$stage$sitename_var"
    else
      tar -zxf "$folderpath/sitebackups/$site_from/prod/$Namef" -C "$site_path/$stage$sitename_var"
    fi
    # now tar it so it is backed up for future use while we are at it.
    #tar --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.local.php' --exclude='$site_path/$sitename_var/$webroot/sites/default/settings.php' -zcf "$folderpath/sitebackups/prod/$bname.tar.gz" "$site_path/$sitename_var"
    store_sitename_var=$sitename_var
    sitename_var="$stage$sitename_var"

    echo "Fix site settings"
    fix_site_settings

    echo "Set site permissions"
    set_site_permissions $sitename_var

    #restore db
    db_defaults
    echo -e "$Cyan Restore the database $Color_Off"
    restore_db
    echo -e "$Cyan Files and database have been restored $Color_Off"
    sitename_var=$store_sitename_var
    drush @$sitename_var uli &
    echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))

    exit 0

  else
    echo "Restoring $site_from site to site: $stage$sitename_var "
    sitename_var="$stage$sitename_var"

    if [ "${bk: -4}" = "prod" ]; then
      siteto_var_len=$(echo -n $bk | wc -m)
      sitename_pre=${bk:0:$(($siteto_var_len - 5))}
      ocmsg "Goto $folderpath/sitebackups/$sitename_pre/prod/" debug
      cd "$folderpath/sitebackups/$sitename_pre/prod/"
      bk="${sitename_pre}/prod"
    else
      cd "$folderpath/sitebackups/$bk"
      ocmsg "Goto $folderpath/sitebackups/$bk" debug
    fi
    ocmsg "bk: $bk " debug
    ocmsg "flag_first is $flag_first" debug
    options=($(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t))
    if [[ $flag_first ]]; then
      echo -e "\e[34mrestoring $1 to $2 with latest backup\e[39m"
      Name=${options[0]:2}
      echo "Restoring with $Name"
    else
      prompt="Please select a backup:"
      PS3="$prompt "
      select opt in "${options[@]}" "Quit"; do
        if ((REPLY == 1 + ${#options[@]})); then
          exit
        elif ((REPLY > 0 && REPLY <= ${#options[@]})); then
          echo "You picked $REPLY which is file ${opt:2}"
          Name=${opt:2}
          break
        else
          echo "Invalid option. Try another one."
        fi
      done
    fi
  fi
fi

if [[ "$step" -lt 3 ]]; then

  echo " site_path: $site_path/$sitename_var"
  # Check to see if folder already exits.
  if [[ -d "$site_path/$sitename_var" ]]; then
    if [[ ! "$flag_yes" == "1" ]]; then
      read -p "$sitename_var exists. If you proceed, $sitename_var will first be deleted. Do you want to proceed?(Y/n)" question
      case $question in
      n | c | no | cancel)
        echo exiting immediately, no changes made
        exit 1
        ;;
      esac
    fi
    rm -rf "$site_path/$sitename_var"

  fi
fi
if [[ "$step" -lt 4 ]]; then
  echo -e "\e[34mrestoring files\e[39m"
  # Will need to first move the source folder ($bk) if it exists, so we can create the new folder $sitename_var
  echo "path $site_path/$sitename_var folderpath $folderpath"

  mkdir "$site_path/$sitename_var"
  echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz into $site_path/$sitename_var"
  # Check to see if the backup includes the root folder or not.
  Dir_name=$(tar -tzf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" | head -1 | cut -f1 -d"/")
  #echo "Dir_name = >$Dir_name<"
  if [[ $Dir_name == "." ]]; then
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C "$site_path/$sitename_var"
  else
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C "$site_path/$sitename_var" --strip-components=1
  fi

# Move settings.php and settings.local.php out the way before they are overwritten just in case you might need them.
#echo "Moving settings.php and settings.local.php"
#setpath="$site_path/$sitename_var/$webroot/sites/default"
#if [[ -f "$setpath/settings.php" ]] ; then mv "$setpath/settings.php" "$setpath/settings.php.old" ; fi
#if [[ -f "$setpath//settings.local.php" ]] ; then mv "$setpath//settings.local.php" "$setpath/settings.local.php.old" ; fi
#if [[ -f "$setpath//default.settings.php" ]] ; then mv "$setpath//default.settings.php" "$setpath//settings.php" ; fi

### do I need to deal with services.yml?
fi

if [[ "$step" -lt 5 ]]; then

  fix_site_settings
fi

if [[ "$step" -lt 6 ]]; then
  echo "Set site permissions"
  set_site_permissions $sitename_var
fi

if [[ "$step" -lt 7 ]]; then
  #restore db
  db_defaults
  echo -e "$Cyan Restore the database $Color_Off"
  restore_db
  echo -e "$Cyan Files and database have been restored $Color_Off"
fi

if [[ "$step" -lt 8 ]]; then
  if [[ $flag_open ]]; then
    drush @$sitename_var uli &
  fi
fi
#drush @sitename_var cr
# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
exit 0
