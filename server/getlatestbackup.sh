#!/bin/bash
# This just prints the latest sql backup for a particular site.

if [ -z "$1" ]; then
exit 1
else
prod_uri=$1
fi
cd
cd $prod_uri
   options=($(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t))
   Name=${options[0]:2}
echo "${Name}"
exit 0

