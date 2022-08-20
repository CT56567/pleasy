#!/bin/bash

print_help() {
echo \
"Overwrite the stage site with production
Usage: pl proddownr [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: The local site will be deleted if it already exists.
Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function
  -y --yes                Answer yes to all prompts


Examples:
pl proddownr stg_d9
pl proddownr stg_d9 -s=2
END HELP"

}



# start timer
# Timer to show how long it took to run the script
SECONDS=0

# step is defined for script debug purposesstep=${step:-1}

args=$(getopt -o hs:dy -l help,step:,debug,yes --name "$scriptname" -- "$@")

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl proddownr --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
# pdmethod (proddown method) is presumed to be tar unless otherwise specified.
pdmethod="rsync"
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2 # works
    ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
  -y | --yes)
    flag_yes=1
    shift; ;;
#  -t | --test)
#    test="y"
#    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

parse_pl_yml
sitename_var=$1
if [ $1 = "proddownr" ] && [ -z "$2" ]; then
  echo "No site specified, exiting"
fi

# Make sure @prod is setup.
update_all_configs
import_site_config $sitename_var
echo "step $step"

  if [ "${sitename_var:0:3}" = "stg" ]; then
    # set up stg
    sitename_short=${sitename_var:4}
  else
    if [ ! "$flag_yes"  ]; then
      #Double check!
      echo "You have chosen a non-stg target, ie $sitename_var. Do you want to proceed - type y"
      read proc
      if [ "$proc" != "y" ]; then
        exit
      else
        echo "Proceeding"
      fi
    fi
    sitename_short=$sitename_var
  fi
sitename_store=$sitename_var

echo "Importing $sitename_short production site into $sitename_var"

if [[ "$step" -gt 1 ]] ; then
  echo "Starting from step $step"
fi

if [[ "$step" -lt 2 ]] ; then
  echo -e "$Cyan step 1: backup production $Color_Off"
  rsync_var=$sitename_var
  sitename_var="prod_$sitename_short"
  site_to="${sitename_short}_prod"
  msg="proddown"
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

  # sql file: $Namesql
  # all files: $folderpath/sitebackups/prod/$Name.tar.gz
sitename_var=$sitename_store
fi

exit

if [[ "$step" -lt 3 ]] ; then
  echo -e "$Cyan step 2: restore database ${sitename_short}_prod to $sitename_var $Color_Off"
    #restore db
    db_defaults
    echo -e "$Cyan Restore the database $Color_Off"
    restore_db
    echo -e "$Cyan Files and database have been restored $Color_Off"
    echo -e "$Cyan Opening $sitename_var $Color_Off"
    sitename_var=$store_sitename_var
pl open "$sitename_var"

fi
#

# Make sure url is setup and open it!
#pl sudoeuri localprod
echo -e "$Cyan Opening $sitename_var $Color_Off"
pl open "$sitename_var"
# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
