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
  uri=$1
fi

if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi

if [ -z "$3" ] ; then
echo "No profile."
exit 0
else
profile=$3
fi

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"


echo "Update Production"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Test uri: $test_uri"
echo "User: $user"
echo "Profile: $profile"

# prod files at prod.tar.gz
# prod db at ~/proddb/prod.sql
#  Presumes the files are transfered.
mv /home/$user/$uri/prod.tar.gz $(dirname $prod)
tar -zxf $(dirname $prod)/prod.tar.gx $uri

mv /home/$user/$uri/prod.tar.gz $(dirname $prod)
tar -zxf $(dirname $prod)/prod.tar.gx $test_uri

cd
sudo ./dfp.sh --drupal_user=$user --drupal_path=$prod_docroot
sudo ./dfp.sh --drupal_user=$user --drupal_path=$test_docroot
# Create the settings file.

./createsite.sh $uri $profile
./createsite.sh $test_uri $profile

#dbname=$(sudo grep "'database' =>" $1/sites/default/settings.php  | cut -d ">" -f 2 | cut -d "'" -f 2 | tail -1)



echo "Sites created."

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
