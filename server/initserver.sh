#!/bin/bash

SECONDS=0

# Update the prod site.
# It is presumed the site files have been uploaded.

# Step Variable
################################################################################
# Variable step is defined for debug purposes. If the init fails, we can,
# using step, start at the point of the script which had failed
################################################################################
step=${step:-1}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are --yes --help --step
################################################################################
args=$(getopt -o yhs:ndt -l yes,help,step:,nopassword,debug,test --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
  echo "please do './pl init --help' for more options"
  exit 1
}

# Set getopt parse backup into $@
################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# if no argument passed, default is -- and break loop
################################################################################
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

if [[ "$1" == "initserver" ]] && [[ -z "$2" ]]; then
 echo "No site specified."
elif [[ "$1" == "initserver" ]] ; then
  prod_docroot=$2
elif [[ -z "$1" ]]; then
 echo "No site specified."
else
  prod_docroot=$1
fi


if [ -z "$2" ] ; then
echo "No user given."
exit 0
else
user=$2
fi


prod_docroot=$1
webroot=$(basename $1)
prod=$(dirname $1)
#test_uri="test.$uri"
#test_docroot="$(dirname $prod)/$test_uri/$webroot"
#test="$(dirname $prod)/$test_uri"


echo "Update Production"
#echo "Test site: $test"
#echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $uri"
#echo "Test uri: $test_uri"
echo "User: $user"

#!/bin/bash
./secrets.sh

apt update && apt upgrade -y
# apt-get -o Dpkg::Options::="--force-confnew --force-confdef" --force-yes -y upgrade
# adduser $user
sudo adduser $user --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
echo "$user:$pword" | sudo chpasswd

usermod -aG sudo $user
ufw allow OpenSSH
ufw enable -y
ufw status

echo "$user ALL=(ALL:ALL) NOPASSWD: ALL" | EDITOR="tee -a" visudo

echo """send private key to server.
ssh-keygen
ssh-copy-id -i $key $user@$ip"
read  -n 1 -p "Is ssh keys set up?" mainmenuinput

#Stop password authentication
sudo sed 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE
sudo sed -i 's/#\?\(PasswordAuthentication\s*\).*$/\1 no/' /etc/ssh/sshd_config
sudo systemctl restart ssh -y


exit 0

sudo apt install mariadb-server -y
sudo mysql_secure_installation
sudo systemctl status mysql

mysql -u root -p

#need to use
# sudo mysql
# use mysql;
# ALTER USER 'root'@'localhost' IDENTIFIED BY 'PASSWORD_HERE';
# now the password will be set. mysql_secure_installation does not set the password!!!!




sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo apt install php php-fpm php-gd php-common php-mysql php-apcu php-gmp php-curl php-intl php-mbstring php-xmlrpc php-gd php-xml php-cli php-zip -y

#date.timezone = Australia/Melbourne
#memory_limit = 256M
#upload_max_filesize = 64M
#max_execution_time = 600
#cgi.fix_pathinfo = 0
sudo sed -i "s/\(date.timezone *= *\).*/\1 Australia\/Melbourne/" /etc/php/7.4/fpm/php.ini
sudo sed -i '/date.timezone *=* Australia\/Melbourne/s/^;//' /etc/php/7.4/fpm/php.ini
sudo sed -i "s/\(memory_limit *= *\).*/\1 256M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/\(upload_max_filesize *= *\).*/\1 64M/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/\(max_execution_time *= *\).*/\1 600/" /etc/php/7.4/fpm/php.ini
sudo sed -i "s/\(cgi.fix_pathinfo *= *\).*/\1 0/" /etc/php/7.4/fpm/php.ini
sudo sed -i '/cgi.fix_pathinfo *=* 0/s/^;//' /etc/php/7.4/fpm/php.ini

sudo systemctl restart php7.4-fpm
sudo systemctl enable php7.4-fpm

sudo apt install certbot -y
sudo systemctl stop nginx
certbot certonly --rsa-key-size 2048 --standalone --agree-tos --no-eff-email --email $email -d $uri



# Transfer the files first.
# Create the settings file.

# Step 1
################################################################################
# Attempt to install gawk
################################################################################
if [[ "$step" -lt 2 ]]; then
  echo -e "$Cyan step 1: Will need to install gawk - sudo required $Color_Off"
  # This is needed to avoid the awk: line 43: functionWill
  # need to install gawk - sudo required asorti never
  # defined error

  #echo "test mysql"
  #result=$(mysql -e 'CREATE DATABASE test;' 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  #echo "result2: >$result<"
  #
  #if [[ "$result" != ": 0" ]]; then
  #  echo "mysql did not work"
  #  mysql -e 'CREATE DATABASE test;'
  #  fi
  #echo "did it work?"

#  if [[ "$nopassword" == "y" ]]; then
#    # set up user with sudo
    echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo EDITOR="tee -a" visudo
#
#  # This could be improved with creating specific scripts that would complete any sudo tasks and each of these be given
#  # nopasswd permission. This would reduce the security risk of the above command.
#
#  fi
#  # Appears that Ubuntu 20 needs this for gawk to be installed.
#  sudo apt-get install build-essential -y
#  sudo apt-get install gawk -y
#  gout=$(gawk -Wv)
#  gversion=${gout:8:1}
#  echo "Gawk version: >$gversion<"
#
#  if [[ "$gversion" == "5" ]]; then
#    echo "Need to purge gawk and install version 4 of gawk"
#    1:4.1.4+dfsg-1build1
#    sudo apt-get remove gawk -y
#
#    wget https://ftp.gnu.org/gnu/gawk/gawk-4.2.1.tar.gz
#    tar -xvpzf gawk-4.2.1.tar.gz
#    cd gawk-4.2.1
#    sudo ./configure && sudo make && sudo make install
#    sudo apt install gawk=1:5.0.1+dfsg-1
#  # It installs 5.0.1, but when you run gawk -Wv it says it 4.2.1. Anyway it works. I don't know another way of doing it.
#  fi
fi
#
## Step 2
#################################################################################
## This step must run, regardless of statement since the functions must be included for any other steps to be able to run
## Since the following steps will need the variables that will be accessible only if parse_pl_yml is run.
#################################################################################
#echo -e "$Cyan step 2 (must be run): checking if folder $sitename_var exists $Color_Off"
#echo running include files...
## This includes all the functions in _inc.sh for use by init.sh @JamesCHLim
#. "$script_root/_inc.sh"
#ocmsg "parsing yml" debug
#ocmsg "location: $folderpath/pl.yml" ocmsg
#if [ ! -f "$folderpath/pl.yml" ]; then
#  ocmsg "Copying example.pl.yml to pl.yml and setting some defaults based on the system." debug
#  cp $folderpath/example.pl.yml $folderpath/pl.yml
#  # set the user
#  sed -i "s/stcarlos/$USER/g" $folderpath/pl.yml
#fi
## When using parse_pl_yml for the first time, ie as part init.sh, there is no need to update the script, since it
## doesn't need updating. Updating will cause problems. So we need to make sure it doesn't update by setting the
## no_config_update to "true". This is the only time it is set to true. We also don't want it to run if we are
## rerunning the init.sh script.
#no_config_update="true"
## Import yaml, presumes $script_root is set
#parse_pl_yml
##echo "wwwpath $www_path"

# Step 3
################################################################################
# Adding pl command to bash commands, including plextras
################################################################################
#if [ $step -lt 4 ]; then
#  echo -e "$Cyan step 3: Adding pl command to bash commands, including plextras $Color_Off"
#
#  update_locations
#
#  #prep up the debug command with cli and apached locations
#  echo "adding debug command"
#  ocbin="/home/$user/$project/bin"
#  sed -i "3s|.*|phpcli=\"$phpcli\"|" "$ocbin/debug"
#  sed -i "4s|.*|phpapache=\"$phpapache\"|" "$ocbin/debug"
#
#  #set up d8fp, debug and sudoeuri to run without password
#  echo -e "$Cyan \n Make fixing folder permissions and debug run without sudo $Color_Off"
#  sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath/bin" $user
#  echo "export PATH=\"\$PATH:/usr/local/bin/\"" >>~/.bashrc
#  # todo check this code
#  #echo ". /usr/local/bin/debug" >>~/.bashrc
#
#  cd
#  source ~/.bashrc
##plsource
#fi

## Step 4
#################################################################################
## Create mysql root password file
#################################################################################
#if [ $step -lt 5 ]; then
#  echo -e "$Cyan step 4: Create mysql root password file $Color_Off"
#  # Create mysql root password file
#  # Check if one exists
#  if [ ! -f $(dirname $script_root)/mysql.cnf ]; then
#    echo "Creating $(dirname $script_root)/mysql.cnf"
#
#    if [[ "$pltest" == "y" ]]; then
#      echo "Testing: mysql root setup at  $(dirname $script_root)/mysql.cnf"
#      cat >$(dirname $script_root)/mysql.cnf <<EOL
#[client]
#user=root
#password=root
#host=localhost
#EOL
#    else
#      cat >$(dirname $script_root)/mysql.cnf <<EOL
#[client]
#user=root
#password=root
#host=localhost
#EOL
#      #Check if mysql is installed
#      if type mysql >/dev/null 2>&1; then
#        # User needs to add mysql root credentials.
#        echo "mysql already installed. Please edit $(dirname $script_root)/mysql.cnf with your mysql root credentials."
#      fi
#    fi
#  else
#    echo "mysql.cnf already exists"
#  fi
##sudo chmod 0600 $(dirname $script_root)/mysql.cnf
#
#fi

# Step 5
################################################################################
# Updating System..
################################################################################
#if [ $step -lt 6 ]; then
#  echo -e "$Cyan step 5: Updating System..  $Color_Off"
#  # see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
#  # Update packages and Upgrade system
#  sudo apt-get -qqy update && sudo apt-get -qqy upgrade
#
#  # Setup php 7.3
#  sudo apt-get -y install software-properties-common
#  sudo add-apt-repository -y ppa:ondrej/php
#  sudo add-apt-repository -y ppa:ondrej/apache2
#  #
#  sudo apt -qqy update
#
#  ## Install AMP
#  echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
#  # php-gettext not installing on ubuntu 20
#  #sudo apt-get -qq install apache2 php libapache2-mod-php php-mysql php-gettext curl php-cli php-gd php-mbstring php-xml php-curl php-bz2 php-zip git unzip php-xdebug -y
#  # Install vim to make sure arrow keys work properly.
#  sudo apt-get -y install apache2 php7.3 libapache2-mod-php7.3 php7.3-mysql php7.3-common curl php7.3-cli php7.3-gd php7.3-mbstring php7.3-xml php7.3-curl php7.3-bz2 php7.3-zip git unzip php-xdebug vim -y
#
#  # If Travis, then add some environment variables, particularly to add more memory to php.
##  echo "pwd: $(pwd)"
##  if [[ "$(pwd)" == "/home/travis" ]]; then
##    cd build/rjzaar
##    phpenv version
##    echo 'max_execution_time = 1200' >>varbase.php.ini
##    echo 'max_input_time = 180' >>varbase.php.ini
##    echo 'max_input_vars = 10000' >>varbase.php.ini
##    echo 'memory_limit = 4000M' >>varbase.php.ini
##    echo 'error_reporting = E_ALL' >>varbase.php.ini
##    echo 'post_max_size = 64M' >>varbase.php.ini
##    echo 'upload_max_filesize = 32M' >>varbase.php.ini
##    echo 'max_file_uploads = 40' >>varbase.php.ini
##    echo 'sendmail_path = /bin/true' >>varbase.php.ini
##    echo "phpenv config-add"
##    phpenv config-add varbase.php.ini
##    echo "phpenv rehash"
##    phpenv rehash
##    cd
##  fi
#
## Actually just set the memory limit regardless
#phpline=$(php -i | grep "Loaded Configuration File")
#echo "phpline: $phpline"
#phploc=($phpline)
#echo "phploc ${phploc[4]}"
#phpmem=$(grep '^memory_limit ' ${phploc[4]} )
#echo "phpmem $phpmem"
#sudo sed -i 's,^memory_limit =.*$,memory_limit = -1,' ${phploc[4]}
#phpmem=$(grep '^memory_limit ' ${phploc[4]} )
#echo "$phpmem"
#fi


# Step 7
################################################################################
# Installing MySQL
################################################################################
#if [ $step -lt 8 ]; then
#  echo -e "$Cyan step 7: Installing MySQL $Color_Off"
#  #Check if mysql is installed
#  #if type mysql >/dev/null 2>&1; then
#  #echo "mysql already installed."
#  #else
#  # Not installed
#  # From: https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt
#
#    if [[ "$host_database" == "mysql" ]]; then
#  sudo debconf-set-selections <<<'mysql-server mysql-server/root_password password root'
#  sudo debconf-set-selections <<<'mysql-server mysql-server/root_password_again password root'
#  sudo apt-get -y install mysql-server
#  else
#
#  export DEBIAN_FRONTEND=noninteractive
#  sudo debconf-set-selections <<<'mariadb-server-10.3 mysql-server/root_password password root'
#  sudo debconf-set-selections <<<'mariadb-server-10.3 mysql-server/root_password_again password root'
#  sudo apt-get -y install mariadb-server
#  fi
#
#  # Add good defaults for mariadb from lando
#  # use mysqld --help --verbose to check variables
#  #  This is causing an error.... todo fix mariadb my.cnf
##  sudo wget https://github.com/lando/lando/blob/master/examples/mariadb/config/my.cnf /etc/mysql/mariadb.conf.d/my.cnf
#  #sudo systemctl restart mariadb
#
##fi
#
#fi



# Step 10
################################################################################
#  Install Composer
################################################################################
if [ $step -lt 11 ]; then
  echo -e "$Cyan step 10: Install Composer  $Color_Off"
  #Check if composer is installed otherwise install it
  # From https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-16-04?comment=67716

  cd
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
  php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#mv composer.phar /usr/local/bin/composer

# Not sure why this next line might be needed.... @rjzaar
#sudo chown -R $user .composer/
fi

# Step 11
################################################################################
# Install Drush globally
################################################################################
if [ $step -lt 12 ]; then
  echo -e "$Cyan step 11: Install Drush globally $Color_Off"
  # Install drush globally with drush launcher
  # see: https://github.com/drush-ops/drush-launcher  ### xdebug issues?
  if [ ! -f /usr/local/bin/drush ]; then
    wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
    sudo chmod +x drush.phar
    sudo mv drush.phar /usr/local/bin/drush
    echo "drush installed"
  else
    echo "drush already present."
  fi

  # Also need to install drush globally so drush will work outside of drupal sites
  # see https://www.jeffgeerling.com/blog/2018/drupal-vm-48-and-drush-900-some-major-changes
  # see https://docs.drush.org/en/8.x/install-alternative/  and
  # see https://github.com/consolidation/cgr
  #
  # if there is an issue with swap use this to fix it: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
  comppres="false"
  cd
  #composer global require drush/drush
  echo "composer install consoildation/cgr"
  # sudo ls -la .config
  if [[ -d "/home/$USER/.config" ]]; then
    sudo chown -R $USER "/home/$USER/.config"
    comppres="true"
  fi

  if [[ -d "/home/$USER/.composer" ]]; then
    sudo chown -R $USER "/home/$USER/.composer"
    comppres="true"
  fi
  if [[ "$comppres" == "false" ]]; then
    echo "Don't know where composer is. I thought I installed it.1"
  fi

  # sudo chown -R $USER /home/travis/.composer/
  composer global require consolidation/cgr
  echo "echo path into bashrc"
  cd
  # ls -la

  echo "composer home: $(composer config -g home)"
  comphome=$(composer config -g home)

  echo "export PATH=\"\$PATH:$comphome/vendor/bin\"" >>~/.bashrc
  source ~/.bashrc
  # cat .bashrc

  # https://github.com/consolidation/cgr/issues/29#issuecomment-422852318
  cd /usr/local/bin

  if [[ -d "/home/$USER/.config" ]]; then
    if [[ ! -L './cgr' ]]; then
      echo "Creating symlink"
      sudo ln -s $comphome/vendor/bin/cgr .
    fi
    #sudo ln -s ~/.config/composer/vendor/bin/drush .
    cd
    echo "export DRUSH_LAUNCHER_FALLBACK=$comphome/vendor/bin/drush" >>~/.bashrc
  elif [[ -d "/home/$USER/.composer" ]]; then
    if [[ ! -L ~/.composer/vendor/bin/cgr ]]; then
      if [[ ! -L './cgr' ]]; then
        echo "Creating symlink2"
        sudo ln -s ~/.composer/vendor/bin/cgr .
      fi
      cd
      echo "export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush" >>~/.bashrc
    fi
  else
    echo "Don't know where composer is. I thought I installed it.2"
  fi
  cd
  source ~/.bashrc
  cgr drush/drush
fi

# Step 12
################################################################################
# Install Drupal console globally
################################################################################
if [ $step -lt 13 ]; then
  echo -e "$Cyan step 12: Install Drupal console globally  $Color_Off"
  # Install drupal console
  # see https://drupalconsole.com/articles/how-to-install-drupal-console
  if [ ! -f /usr/local/bin/drupal ]; then
    echo "curl"
    curl https://drupalconsole.com/installer -L -o drupal.phar
    dcon=$(sed '2q;d' drupal.phar)
echo "dcon $dcon"
if [[ "$dcon" == "<html><head>" || "$dcon" == "" ]] ; then

# drupalconsole.com/installer is down. get it form git
rm drupal.phar
git clone https://github.com/rjzaar/drupal.phar.git
mv drupal.phar drupal.pha
mv drupal.pha/drupal.phar drupal.phar
rm drupal.pha -rf
fi
    #could test it
    # php drupal.phar
    sudo mv drupal.phar /usr/local/bin/drupal
    sudo chmod +x /usr/local/bin/drupal
    echo "drupal init"
    drupal init --override --no-interaction
    echo "drupal init finished"
    #Bash or Zsh: Add this line to your shell configuration file:
    #echo "set up source"
    #source "$HOME/.console/console.rc" 2>/dev/null
    echo "put into bashrc"
    echo "source \"$HOME/.console/console.rc\" 2>/dev/null" >>~/.bashrc
    echo "reset source"
    cd
    source ~/.bashrc



  # drupal self-update no longer valid? https://github.com/hechoendrupal/drupal-console/issues/3198
  #echo "drupal self-update"
  #drupal self-update
  else
    echo "Drupal console already present"
  fi
fi



# Step 14
################################################################################
# Fix adding extra characters for vi
################################################################################
if [ $step -lt 15 ]; then
  echo -e "$Cyan step 14: Fix adding extra characters for vi  $Color_Off"
  #Set up vi to not add extra characters
  #From: https://askubuntu.com/questions/353911/hitting-arrow-keys-adds-characters-in-vi-editor
  echo -e "$Cyan \n  $Color_Off"
  cat >$(dirname $script_root)/.vimrc <<EOL
set nocompatible
EOL
fi
echo " open this link to add the xdebug extension for the browser you want to use"
echo "https://www.jetbrains.com/help/phpstorm/2019.3/browser-debugging-extensions.html?utm_campaign=PS&utm_medium=link&utm_source=product&utm_content=2019.3 "

cd


echo "All done!"

exit 0


echo "Server initiated."

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
