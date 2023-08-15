#!/bin/bash
prod_alias="opencat"
cd

  DIRECTORY=$(cd $(dirname $0) && pwd)
  ocmsg "Directory $DIRECTORY"
  echo "pwd $(pwd)"
  cd $(dirname $0)
  echo "Directory: $DIRECTORY pwd: $(pwd)"
  IFS="/" read -ra PARTS <<<"$(pwd)"
  user=$USER
project=${PARTS[3]}
  for ((i = 4 ; i < ${#PARTS[@]}-1 ; i++)); do
    $project=$project +"/"+ ${PARTS[i]}
  done


  echo "Parts 4 ${PARTS[4]}  parts 5 ${PARTS[5]}"
#  if [[ "$project" == "bin" ]] && [[ "$user" == "circleci" ]]; then
#    # Must be a circleci build
#    ocmsg "Circleci Build" debug
#    project="project"
#  fi
  echo "user: $user  project: $project"
  store_project=$project
  # Check correct user name
  if [ ! -d "/home/$user" ]; then
    echo "User name in pl.yml $user does not match the current user's home directory name. Please fix pl.yml."
    exit 1
  fi

