#!/bin/bash
# Expand the variables
# $1 is the prod site. docroot location ie prod_docroot
# From this is expanded
# webroot is the last folder name, eg docroot
# uri is the next folder name, eg example.com
# prod is the rest, eg /var/www/

if [ -z "$1" ]; then
echo "No prod site info provided. Exiting."
exit 0
fi

prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
uri=$(basename $prod)
test_uri="test.$uri"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
test="$(dirname $prod)/$test_uri"

echo "Variables are:"
echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
echo "Test uri: $test_uri"
echo "user: $user"

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

echo "Variables setup."
