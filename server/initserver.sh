#!/bin/bash

set -eux

SECONDS=0
scriptname="$(basename $0)"
Cyan='\033[0;36m'   # Cyan
Color_Off='\033[0m' # Text Reset
pltest="n"
# Update the prod site.
# It is presumed the site files have been uploaded.

# step is defined for script debug purposesstep=${step:-1}
step=1
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
test_uri="test.$url"
test_docroot="$(dirname $prod)/$test_uri/$webroot"
#test="$(dirname $prod)/$test_uri"


echo "setup Production"
#echo "Test site: $test"
echo "Test docroot: $test_docroot"
echo "Prod site: $prod"
echo "Prod docroot: $prod_docroot"
echo "Prod uri: $url"
#echo "Test uri: $test_uri"
echo "User: $user"

# Step 4
# Create mysql root password file
if [[ $step -lt 2 ]]; then
  echo -e "$Cyan step 1: Create mysql root password file $Color_Off"
  # Create mysql root password file
  dbpass=$(date +%N | sha256sum | base64 | head -c 32 ; echo)
  # Check if one exists
  if [ ! -f /home/$user/mysql.cnf ]; then
    echo "Creating /home/$user/mysql.cnf"

    if [[ "$pltest" == "y" ]]; then
      echo "Testing: mysql root setup at  /home/$user/mysql.cnf"
      cat >/home/$user/mysql.cnf<<EOL
[client]
user=root
password=$dbpass
host=localhost
EOL
    else
      cat >/home/$user/mysql.cnf <<EOL
[client]
user=root
password=$dbpass
host=localhost
EOL
      #Check if mysql is installed
      if type mysql >/dev/null 2>&1; then
        # User needs to add mysql root credentials.
        echo "mysql already installed. Please edit /home/$user/mysql.cnf with your mysql root credentials."
      fi
    fi
  else
    echo "mysql.cnf already exists"
  fi
#sudo chmod 0600 $(dirname $script_root)/mysql.cnf

fi

MARIADB_VERSION="$(apt-cache madison mariadb-server | head -n 1 | sed -r 's/.*[0-9]+:([0-9]+\.[0-9]+).*/\1/')"
export DEBIAN_FRONTEND=noninteractive
{
  echo "mariadb-server-$MARIADB_VERSION" mysql-server/root_password password '$dbpass';
  echo "mariadb-server-$MARIADB_VERSION" mysql-server/root_password_again password '$dbpass';
} | sudo debconf-set-selections;

if dpkg -l mariadb-server > /dev/null; then
  echo "WARNING: Mariadb is already installed"
  echo "Script may not be able to setup the DB properly"
  echo "Continuing anyway"
fi

sudo apt install mariadb-server -y

sudo mysql -sfu root <<EOF || true
-- set root password
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$dbpass');
-- delete anonymous users
DELETE FROM mysql.user WHERE User='';
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- drop database 'test'
DROP DATABASE IF EXISTS test;
-- also make sure there are lingering permissions to it
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- make changes immediately
FLUSH PRIVILEGES;
EOF

sudo systemctl status mysql --no-pager

sudo apt install nginx -y
sudo systemctl enable --now nginx
sudo apt install -y --no-install-recommends \
  php \
  php-fpm \
  php-gd \
  php-common \
  php-mysql \
  php-apcu \
  php-gmp \
  php-curl \
  php-intl \
  php-mbstring \
  php-xmlrpc \
  php-gd \
  php-xml \
  php-cli \
  php-zip

#date.timezone = Australia/Melbourne
#memory_limit = 256M
#upload_max_filesize = 64M
#max_execution_time = 600
#cgi.fix_pathinfo = 0
PHP_VERSION="$(apt-cache madison php | head -n 1 | sed -r 's/.*[0-9]+:([0-9]+\.[0-9]+).*/\1/')"

sudo sed -i "s/\(date.timezone *= *\).*/\1 Australia\/Melbourne/" /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i '/date.timezone *=* Australia\/Melbourne/s/^;//' /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i "s/\(memory_limit *= *\).*/\1 256M/" /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i "s/\(upload_max_filesize *= *\).*/\1 64M/" /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i "s/\(max_execution_time *= *\).*/\1 600/" /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i "s/\(cgi.fix_pathinfo *= *\).*/\1 0/" /etc/php/$PHP_VERSION/fpm/php.ini
sudo sed -i '/cgi.fix_pathinfo *=* 0/s/^;//' /etc/php/$PHP_VERSION/fpm/php.ini

sudo systemctl restart php${PHP_VERSION}-fpm
sudo systemctl enable php${PHP_VERSION}-fpm

echo "certbot - ssl cert install if needed"
if [[ ! -f /etc/letsencrypt/renewal/opencat.org.conf ]]; then
  echo "install certificate(s)"
sudo apt install certbot -y
sudo systemctl stop nginx
sudo certbot certonly --rsa-key-size 2048 --standalone --agree-tos --no-eff-email --email $email -d $url -d test.$url
else
  echo "ssl certificate(s) already installed"
fi
# see https://www.nginx.com/resources/wiki/start/topics/recipes/drupal/

sudo cat >/etc/nginx/sites-available/$url <<EOL
server {
    server_name $url;
    root $prod_docroot;

    listen 80;
    listen [::]:80;
    listen 443 default ssl;

    ssl_certificate      /etc/letsencrypt/live/$url/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/$url/privkey.pem;

    # Redirect HTTP to HTTPS
    if (\$scheme = http) {
        return 301 https://\$server_name\$request_uri;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Very rarely should these ever be accessed outside of your lan
    location ~* \.(txt|log)$ {
        allow 192.168.0.0/16;
        deny all;
    }

    location ~ \..*/.*\.php$ {
        return 403;
    }

    location ~ ^/sites/.*/private/ {
        return 403;
    }

    # Block access to scripts in site files directory
    location ~ ^/sites/[^/]+/files/.*\.php$ {
        deny all;
    }

    # Allow "Well-Known URIs" as per RFC 5785
    location ~* ^/.well-known/ {
        allow all;
    }

    # Block access to "hidden" files and directories whose names begin with a
    # period. This includes directories used by version control systems such
    # as Subversion or Git to store control files.
    location ~ (^|/)\. {
        return 403;
    }

     location / {
         # try_files \$uri @rewrite; # For Drupal <= 6
         try_files \$uri /index.php?\$query_string; # For Drupal >= 7
     }

     location @rewrite {
         #rewrite ^/(.*)$ /index.php?q=\$1; # For Drupal <= 6
         rewrite ^ /index.php; # For Drupal >= 7
     }

     # Don't allow direct access to PHP files in the vendor directory.
     location ~ /vendor/.*\.php$ {
         deny all;
         return 404;
     }

     # Protect files and directories from prying eyes.
     location ~* \.(engine|inc|install|make|module|profile|po|sh|.*sql|theme|twig|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|/(\.(?!well-known).*)|Entries.*|Repository|Root|Tag|Template|composer\.(json|lock)|web\.config$|/#.*#$|\.php(~|\.sw[op]|\.bak|\.orig|\.save)$ {
         deny all;
         return 404;
     }

     # In Drupal 8, we must also match new paths where the '.php' appears in
     # the middle, such as update.php/selection. The rule we use is strict,
     # and only allows this pattern with the update.php front controller.
     # This allows legacy path aliases in the form of
     # blog/index.php/legacy-path to continue to route to Drupal nodes. If
     # you do not have any paths like that, then you might prefer to use a
     # laxer rule, such as:
     #   location ~ \.php(/|$) {
     # The laxer rule will continue to work if Drupal uses this new URL
     # pattern with front controllers other than update.php in a future
     # release.
     location ~ '\.php$|^/update.php' {
         fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
         # Ensure the php file exists. Mitigates CVE-2019-11043
         try_files \$fastcgi_script_name =404;
         # Security note: If you're running a version of PHP older than the
         # latest 5.3, you should have "cgi.fix_pathinfo = 0;" in php.ini.
         # See http://serverfault.com/q/627903/94922 for details.
         include fastcgi_params;
         # Block httpoxy attacks. See https://httpoxy.org/.
         fastcgi_param HTTP_PROXY "";
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         fastcgi_param PATH_INFO \$fastcgi_path_info;
         fastcgi_param QUERY_STRING \$query_string;
         fastcgi_intercept_errors on;
         # PHP 5 socket location.
         #fastcgi_pass unix:/var/run/php5-fpm.sock;
         # PHP 7 socket location.
         fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
     }

   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        try_files \$uri @rewrite;
        expires max;
        log_not_found off;
    }

    # Fighting with Styles? This little gem is amazing.
    # location ~ ^/sites/.*/files/imagecache/ { # For Drupal <= 6
    location ~ ^/sites/.*/files/styles/ { # For Drupal >= 7
        try_files \$uri @rewrite;
    }

    # Handle private files through Drupal. Private file's path can come
    # with a language prefix.
    location ~ ^(/[a-z\-]+)?/system/files/ { # For Drupal >= 7
        try_files \$uri /index.php?\$query_string;
    }

    # Enforce clean URLs
    # Removes index.php from urls like www.example.com/index.php/my-page --> www.example.com/my-page
    # Could be done with 301 for permanent or other redirect codes.
    if (\$request_uri ~* "^(.*/)index\.php/(.*)") {
        return 307 \$1\$2;
    }
        access_log /var/log/nginx/opencat.log;
        error_log /var/log/nginx/opencaterror.log;
}
EOL

echo "Is /etc/nginx/sites-enabled/$url linked?"
if [[ ! -L /etc/nginx/sites-enabled/$url ]]; then
sudo ln -s /etc/nginx/sites-available/$url /etc/nginx/sites-enabled/
else
  echo "/etc/nginx/sites-enabled/$url already exists"
fi

#Set up test site
sudo cat >/etc/nginx/sites-available/test.$url <<EOL
server {
    server_name test.$url;
    root $test_docroot;

    listen 80;
    listen [::]:80;

    # Redirect HTTP to HTTPS
    if (\$scheme = http) {
        return 301 https://\$server_name\$request_uri;
    }

    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Very rarely should these ever be accessed outside of your lan
    location ~* \.(txt|log)$ {
        allow 192.168.0.0/16;
        deny all;
    }

    location ~ \..*/.*\.php$ {
        return 403;
    }

    location ~ ^/sites/.*/private/ {
        return 403;
    }

    # Block access to scripts in site files directory
    location ~ ^/sites/[^/]+/files/.*\.php$ {
        deny all;
    }

    # Allow "Well-Known URIs" as per RFC 5785
    location ~* ^/.well-known/ {
        allow all;
    }

    # Block access to "hidden" files and directories whose names begin with a
    # period. This includes directories used by version control systems such
    # as Subversion or Git to store control files.
    location ~ (^|/)\. {
        return 403;
    }

     location / {
         # try_files \$uri @rewrite; # For Drupal <= 6
         try_files \$uri /index.php?\$query_string; # For Drupal >= 7
     }

     location @rewrite {
         #rewrite ^/(.*)$ /index.php?q=\$1; # For Drupal <= 6
         rewrite ^ /index.php; # For Drupal >= 7
     }

     # Don't allow direct access to PHP files in the vendor directory.
     location ~ /vendor/.*\.php$ {
         deny all;
         return 404;
     }

     # Protect files and directories from prying eyes.
     location ~* \.(engine|inc|install|make|module|profile|po|sh|.*sql|theme|twig|tpl(\.php)?|xtmpl|yml)(~|\.sw[op]|\.bak|\.orig|\.save)?$|/(\.(?!well-known).*)|Entries.*|Repository|Root|Tag|Template|composer\.(json|lock)|web\.config$|/#.*#$|\.php(~|\.sw[op]|\.bak|\.orig|\.save)$ {
         deny all;
         return 404;
     }

     # In Drupal 8, we must also match new paths where the '.php' appears in
     # the middle, such as update.php/selection. The rule we use is strict,
     # and only allows this pattern with the update.php front controller.
     # This allows legacy path aliases in the form of
     # blog/index.php/legacy-path to continue to route to Drupal nodes. If
     # you do not have any paths like that, then you might prefer to use a
     # laxer rule, such as:
     #   location ~ \.php(/|$) {
     # The laxer rule will continue to work if Drupal uses this new URL
     # pattern with front controllers other than update.php in a future
     # release.
     location ~ '\.php$|^/update.php' {
         fastcgi_split_path_info ^(.+?\.php)(|/.*)$;
         # Ensure the php file exists. Mitigates CVE-2019-11043
         try_files \$fastcgi_script_name =404;
         # Security note: If you're running a version of PHP older than the
         # latest 5.3, you should have "cgi.fix_pathinfo = 0;" in php.ini.
         # See http://serverfault.com/q/627903/94922 for details.
         include fastcgi_params;
         # Block httpoxy attacks. See https://httpoxy.org/.
         fastcgi_param HTTP_PROXY "";
         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
         fastcgi_param PATH_INFO \$fastcgi_path_info;
         fastcgi_param QUERY_STRING \$query_string;
         fastcgi_intercept_errors on;
         # PHP 5 socket location.
         #fastcgi_pass unix:/var/run/php5-fpm.sock;
         # PHP 7 socket location.
         fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
     }

   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        try_files \$uri @rewrite;
        expires max;
        log_not_found off;
    }

    # Fighting with Styles? This little gem is amazing.
    # location ~ ^/sites/.*/files/imagecache/ { # For Drupal <= 6
    location ~ ^/sites/.*/files/styles/ { # For Drupal >= 7
        try_files \$uri @rewrite;
    }

    # Handle private files through Drupal. Private file's path can come
    # with a language prefix.
    location ~ ^(/[a-z\-]+)?/system/files/ { # For Drupal >= 7
        try_files \$uri /index.php?\$query_string;
    }

    # Enforce clean URLs
    # Removes index.php from urls like www.example.com/index.php/my-page --> www.example.com/my-page
    # Could be done with 301 for permanent or other redirect codes.
    if (\$request_uri ~* "^(.*/)index\.php/(.*)") {
        return 307 \$1\$2;
    }
        access_log /var/log/nginx/opencat.log;
        error_log /var/log/nginx/opencaterror.log;
}
EOL

echo "Is /etc/nginx/sites-enabled/test.$url linked?"
if [[ ! -L /etc/nginx/sites-enabled/test.$url ]]; then
sudo ln -s /etc/nginx/sites-available/test.$url /etc/nginx/sites-enabled/
else
  echo "/etc/nginx/sites-enabled/test.$url already exists"
fi
sudo nginx -t
sudo systemctl restart nginx

# Step 10
#  Install Composer
if [[ $step -lt 11 ]]; then
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
# Install Drush globally
if [[ $step -lt 12 ]]; then
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
  composer global require --ignore-platform-req php consolidation/cgr
  #composer global require consolidation/cgr
  echo "echo path into bashrc"
  cd
  # ls -la

  echo "composer home: $(composer config -g home)"
  comphome=$(composer config -g home)

  vendor_bin_source="export PATH=\"\$PATH:$comphome/vendor/bin\""
  if ! grep "$vendor_bin_source" ~/.bashrc; then
    echo "$vendor_bin_source" >> ~/.bashrc
  fi
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
    drush_source="export DRUSH_LAUNCHER_FALLBACK=$comphome/vendor/bin/drush"
    if ! grep "$drush_source" ~/.bashrc; then
      echo "$drush_source" >> ~/.bashrc
    fi
  elif [[ -d "/home/$USER/.composer" ]]; then
    if [[ ! -L ~/.composer/vendor/bin/cgr ]]; then
      if [[ ! -L './cgr' ]]; then
        echo "Creating symlink2"
        sudo ln -s ~/.composer/vendor/bin/cgr .
      fi
      cd
      drush_source="export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush"
      if ! grep "$drush_source" ~/.bashrc; then
        echo "$drush_source" >> ~/.bashrc
      fi
    fi
  else
    echo "Don't know where composer is. I thought I installed it.2"
  fi
  cd
  source ~/.bashrc
  cgr drush/drush
fi

# Step 12
# Install Drupal console globally
if [[ $step -lt 13 ]]; then
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
    console_source="source \"$HOME/.console/console.rc\" 2>/dev/null"
    if ! grep "$console_source" ~/.bashrc; then
      echo "$console_source" >> ~/.bashrc
    fi
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
# Fix adding extra characters for vi
#if [[ $step -lt 15 ]]; then
#  echo -e "$Cyan step 14: Fix adding extra characters for vi  $Color_Off"
#  #Set up vi to not add extra characters
#  #From: https://askubuntu.com/questions/353911/hitting-arrow-keys-adds-characters-in-vi-editor
#  echo -e "$Cyan \n  $Color_Off"
#  cat >$(dirname $script_root)/.vimrc <<EOL
#set nocompatible
#EOL
#fi

if [[ $step -lt 16 ]]; then
  echo -e "$Cyan step 15: Add email tools  $Color_Off"

# todo This needs work. Dumping some of what is needed for now.

# DKIM setup https://www.linuxbabe.com/mail-server/setting-up-dkim-and-spf
#sudo apt-get install postfix opendkim opendkim-tools
# sudo gpasswd -a postfix opendkim

# Should also setup email forwarding https://www.binarytides.com/postfix-mail-forwarding-debian/ see point 3.

fi


echo " open this link to add the xdebug extension for the browser you want to use"
echo "https://www.jetbrains.com/help/phpstorm/2019.3/browser-debugging-extensions.html?utm_campaign=PS&utm_medium=link&utm_source=product&utm_content=2019.3 "

cd

echo "All done!"

exit 0


echo "Server initiated."

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
