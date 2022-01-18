#!/bin/bash



if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
elif [[ -z "$2" ]]; then
 echo "No message specified."
else
prod_docroot=$1
  msg="'$*'"
fi
sitename_var_len=$(echo -n $prod_docroot | wc -m)
msg=${msg:$(($sitename_var_len+2)):-1}
msg="${msg// /_}"

echo "Backup site at $1 with message $msg"
user=$USER
prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
# if uri is test, then the database will be in prod
  if [ "${uri:0:4}" = "test" ]; then
      prod_uri=${uri:5}
      echo "prod uri: $prod_uri"
  fi


echo "Backup Site $prod"
echo "Docroot: $prod_docroot"
echo "Uri: $uri"
echo "Webroot: $webroot"

 #backup db.
  #use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
  cd
  # Check if site backup folder exists
  if [ ! -d "$uri" ]; then
    echo "directory $uri doesn't exist - creating it."
    mkdir "$uri"
  fi

  if [ ! -d "$prod_docroot" ]; then
    echo "No site folder $prod_docroot so no need to backup"
    exit
  fi
    cd "$prod"
    #this will not affect a current git present
    git init
    cd "$webroot"
    msg="${msg// /_}"
    Name=$(date +%Y%m%d\T%H%M%S-)$(git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g')-$(git rev-parse HEAD | cut -c 1-8)$msg.sql

    echo -e "\e[34mbackup db $Name\e[39m"
    # Make database smaller.
    drush cr
    # Could add more directives to make database even smaller.
    drush sql-dump --result-file="/home/$user/$uri/$Name"

    #backupfiles
    Name2=${Name::-4}".tar.gz"

    echo -e "\e[34mbackup files $Name2\e[39m"
    cd $prod/..
    tar -czf /home/$user/$uri/$Name2 $uri
echo "Backup $Name2 is completed."

