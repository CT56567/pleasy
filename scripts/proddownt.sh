#!/bin/bash

print_help() {
echo \
"Overwrite the stage site with production using tar
Usage: pl proddownt [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: If the local site will be deleted if it already exists.
Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function
  -y --yes                Answer yes to all prompts


Examples:
pl proddownt stg_d9
pl proddownt stg_d9 -s=2
END HELP"

}



# start timer
# Timer to show how long it took to run the script
SECONDS=0

# step is defined for script debug purposesstep=${step:-1}

args=$(getopt -o hs:dry -l help,step:,debug,yes --name "$scriptname" -- "$@")

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
    echo "please do 'pl proddownt --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
# pdmethod (proddown method) is presumed to be tar unless otherwise specified.
pdmethod="tar"
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
  -r | --rsync)
    pdmethod="rsync"
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
if [ $1 = "proddownt" ] && [ -z "$2" ]; then
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
  backup_prod
  # sql file: $Namesql
  # all files: $folderpath/sitebackups/prod/$Name.tar.gz
sitename_var=$sitename_store
fi

if [[ "$step" -lt 3 ]] ; then
  echo -e "$Cyan step 2: restore ${sitename_short}_prod to $sitename_var $Color_Off"
  if [[ "$verbose" == "debug" ]]; then
  pl restore "${sitename_short}_prod" "$sitename_var" -yfd
  else
  pl restore "${sitename_short}_prod" "$sitename_var" -yf
  fi
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
