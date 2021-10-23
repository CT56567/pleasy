#!/bin/bash

SECONDS=0

# Update the prod site.
# It is presumed the site files have been uploaded.
# $1 is the site address including docroot.
# $2 is the user



if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
else
  prod_docroot=$1
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi

webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Creating Sites"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Test uri: $test_uri"
echo "User: $user"

#Check if variables are empty
if [[ "$test" = "" ]]; then
  echo "test site variable is empty. Aborting."
  exit 1
fi
if [[ "$test_docroot" = "" ]]; then
  echo "test site docroot variable is empty. Aborting."
  exit 1
fi
if [[ "$prod" = "" ]]; then
  echo "prod site variable is empty. Aborting."
  exit 1
fi
if [[ "$prod_docroot" = "" ]]; then
  echo "prod site docroot variable is empty. Aborting."
  exit 1
fi
if [[ "$uri" = "" ]]; then
  echo "uri variable is empty. Aborting."
  exit 1
fi
if [[ "$user" = "" ]]; then
  echo "user variable is empty. Aborting."
  exit 1
fi

# prod files at prod.tar.gz
# prod db at ~/proddb/prod.sql
#  Presumes the files are transfered.
#sudo rm $prod -rf
#sudo mkdir $prod
#sudo rm $test -rf
#sudo mkdir $test
#
#sudo tar -zxf /home/$user/$uri/prod.tar.gz -C $prod --strip-components 1
#sudo tar -zxf /home/$user/$uri/prod.tar.gz -C $test --strip-components 1

cd
#sudo ./dfp.sh --drupal_user=$user --drupal_path=$prod_docroot
#sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot
# Create the settings file.
echo -e "\e[34mrestoring files\e[39m"
echo "Create prod directories"
sudo rm -rf /var/www/$uri && sudo mkdir /var/www/$uri
sudo rm -rf /var/www/test.$uri && sudo mkdir /var/www/test.$uri 

echo "Unpack site to prod and test locations"
sudo tar -zxf $uri/prod.tar.gz --directory /var/www/$uri --strip-components=1
sudo tar -zxf $uri/prod.tar.gz --directory /var/www/test.$uri --strip-components=1

echo "fix file permissions, requires sudo on external server and Restoring correct settings.php"
sudo chown $user:www-data /var/www/$uri -R
sudo chown $user:www-data /var/www/test.$uri -R

echo "Files installed"

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
