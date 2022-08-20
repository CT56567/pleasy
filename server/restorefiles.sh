#!/bin/bash

print_help() {
  cat <<-HELP
Restore a particular site's files from backup
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.
If the [FROM] site is prod, and the production method is git, git will be used to restore production

OPTIONS
  -h --help               Display help (Currently displayed)
  -f --first              Use the latest backup

HELP
}
args=$(getopt -a -o hf -l help,first --name "$scriptname" -- "$@")
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
  -f | --first)
    flag_first=1
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


#./secrets.sh
#restoreprod

#eval "$(ssh-agent)"
#ssh-add /home/$user/.ssh/$prod_key
echo "Restore site at $1."

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
else
prod_docroot=$1
fi

user=$USER
prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
prod_root=$(dirname $prod)
# if uri is test, then the database will be in prod
  if [ "${uri:0:4}" = "test" ]; then
      prod_uri=${uri:5}
      echo "prod uri: $prod_uri"
  fi


echo "Site $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"
echo "Webroot: $webroot"


cd /home/$USER/$uri

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

if [[ -d "$prod" ]]; then
  echo "prod $prod"
  sudo rm "$prod" -rf
fi

sudo mkdir "$prod"
echo "Untaring /home/$user/$uri/${Name::-4}.tar.gz into $prod"
sudo tar -zxf "/home/$user/$uri/${Name::-4}.tar.gz" --directory   "$prod" --strip-components=1
wait
#cd $1/..
#git reset --hard

