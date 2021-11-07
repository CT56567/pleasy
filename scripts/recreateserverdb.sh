#!/bin/bash
#                          recreateserverdb For Pleasy Library
#
#  This script will recreate the server database
#
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
#                                TODO LIST
#
# scriptname is set in pl.

# Help menu
# Prints user guide
print_help() {
cat << HEREDOC
Recreate the server Database
Usage: pl createserverdb [OPTION] ... [SITE]

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options

Examples:
pl recreateserverdb loc
END HELP
HEREDOC

}

# start timer
# Timer to show how long it took to run the script
SECONDS=0

# Use of Getopt
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
args=$(getopt -o hs:dy -l help,step:,debug,yes --name "$scriptname" -- "$@")

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
  echo "No site specified."
    echo "please do 'pl $scriptname --help' for more options"
    exit 1
}

# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# If no argument passed, default is -- and break loop
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 0; ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
  verbose="debug"
  shift
  ;;
  -y | --yes)
    yes=1
    shift; ;;
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done

Pcolor=$Cyan


if [ $1 = "$scriptname" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 0
fi

sitename_var=$1

echo "overwriting production server with $sitename_var site using rsync method"

parse_pl_yml

import_site_config $sitename_var

if [ $step -gt 1 ] ; then
  echo -e "Starting from step $step"
fi
prod_root=$(dirname $prod_docroot)



if [ $step -lt 2 ] ; then
echo -e "$Pcolor step 1: recreate the server DB $Color_off"
    ssh $prod_alias "./recreatedb.sh $prod_docroot $prod_user"
fi

if [ $step -lt 3 ] ; then
echo -e "$Pcolor step 2: check status $Color_off"
drush @prod_${sitename_var} cr &
drush @prod_${sitename_var} status &
fi
# If it works, the production site needs to be swapped to prod branch from dev branch and hard rest to dev, is use 'ours'.

# End timer
# Finish script, display time taken
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0

