#!/bin/bash
prod_alias="opencat"
step=4

if[ "$step" -lt "4" ]; then
  echo "is less than"
else
  echo "not less than"
  fi

   prod_backups=$(ssh $prod_alias "cd /home/opencat/opencat.org/ && echo \"($(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t))\" ")
   Name=($prod_backups)
   echo ${Name:3}
