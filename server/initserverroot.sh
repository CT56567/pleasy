#!/bin/bash

set -eux

SECONDS=0
scriptname="$(basename $0)"

# Update the prod site.
# It is presumed the site files have been uploaded.

# step is defined for script debug purposesstep=${step:-1}

args=$(getopt -o yhs:ndt -l yes,help,step:,nopassword,debug,test --name "$scriptname" -- "$@")
# echo "$args"

# If getopt outputs error to error variable, quit program displaying error
[ $? -eq 0 ] || {
  echo "please do './pl init --help' for more options"
  exit 1
}


# Set getopt parse backup into $@
# Arguments are parsed by getopt, are then set back into $@
eval set -- "$args"

# Case through each argument passed into script
# if no argument passed, default is -- and break loop
while true; do
  case "$1" in
  -s | --step)
    shift
    step="$(echo "$1" | sed 's/^=//g')"
    #echo "$step"
    # If step is in an invalid range, display invalid and exit program
    if [[ $step -gt 15 || $step -lt 1 ]]; then
      {
        echo "Invalid step value "$step" - valid range [1,15]"
        exit 1
      }
    fi
    ;;
  -y | --yes)
    yes="y"
    ;;
  -d | --debug)
    verbose="debug"
    ;;
  -n | --nopassword)
    nopassword="y"
    ;;
  -t | --test)
    pltest="y"
    ;;
  -h | --help)
    print_help
    exit 3 # pass
    ;;
  --)
    shift
    break
    ;;
  *)
    # *) should not occur with getopt, if it does, there is a bug
    echo "Programming error! Parse argument should not be passed"
    exit 1
    ;;
  esac
  shift
done

#!/bin/bash
source secrets.sh
ip=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
webroot=$(basename $prod_docroot)
prod=$(dirname $prod_docroot)
#test_uri="test.$url"
#test_docroot="$(dirname $prod)/$test_uri/$webroot"
#test="$(dirname $prod)/$test_uri"


echo "setup Production"
#echo "Test site: $test"
#echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $url"
#echo "Test uri: $test_uri"
echo "User: $user"



apt update && apt upgrade -y

#Setup the timezone set in the secrets file. This should match the dev machine.
timedatectl set-timezone "$server_timezone"
# see line 320 in init.sh.
  #setup unattended upgrades
  sudo apt install unattended-upgrades
  #todo setup the config for this
  # https://linoxide.com/enable-automatic-updates-on-ubuntu-20-04/
  # https://www.cyberciti.biz/faq/set-up-automatic-unattended-updates-for-ubuntu-20-04/

#From: https://haydenjames.io/how-to-enable-unattended-upgrades-on-ubuntu-debian/
#APT::Periodic::Update-Package-Lists "1";
#APT::Periodic::Unattended-Upgrade "1";
#APT::Periodic::Download-Upgradeable-Packages "1";
#APT::Periodic::AutocleanInterval "1";

# apt-get -o Dpkg::Options::="--force-confnew --force-confdef" --force-yes -y upgrade
# adduser $user
if ! id -u $user; then
  sudo adduser $user --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
fi
echo "$user:$pword" | sudo chpasswd

usermod -aG sudo $user
ufw allow OpenSSH
ufw allow http
ufw allow https
ufw enable
ufw status

user_sudo_enable="$user ALL=(ALL:ALL) NOPASSWD: ALL" 
if ! grep "$user_sudo_enable" /etc/sudoers; then
  echo "$user_sudo_enable" | EDITOR="tee -a" visudo
fi

# copy over ssh auth in new user
echo "Copying over SSH auth from $USER to $user"

sudo mkdir -p /home/$user/.ssh
sudo cp -p $HOME/.ssh/authorized_keys /home/$user/.ssh/authorized_keys
sudo chown $user:$user /home/$user/.ssh/authorized_keys

# Stop password authentication
sudo sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/g' /etc/ssh/sshd_config
sudo systemctl restart ssh

echo "All done for root part. Now run initserver from $user."
echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
exit 0





