#!/bin/bash
Color_Off='\033[0m' # Text Reset

# Regular Colors
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan

echo -e "$Cyan"
#creates a files backup of opencat.
if [ -z $1 ] ; then
    echo "You have not specified a site"
    exit 1
fi
if [ -z $2 ] ; then
    echo "You have not specified a message"
    exit 1
fi
# Get variables
./secrets.sh
./expandvar.sh $1

if [[ -z $prod_docroot ]] ; then
echo "The site does not exist"
exit 1
fi

cd $(dirname $prod_docroot)
eval "$(ssh-agent)"
ssh-add /home/$user/.ssh/$prod_key
# Now push the site to git.
git add .
git commit -m "backup$2"
git push
echo -e "$Color_Off"
