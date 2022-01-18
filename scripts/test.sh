#!/bin/bash
prod_alias="opencat"
   prod_backups=$(ssh $prod_alias "cd /home/opencat/opencat.org/ && echo \"($(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t))\" ")
   Name=($prod_backups)
   echo ${Name:3}
