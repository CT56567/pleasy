# Pleasy

[![Build Status](https://travis-ci.com/rjzaar/pleasy.svg?branch=master)](https://travis-ci.com/rjzaar/pleasy)

This is a Devops framework for drupal sites, particularly based on varbase.
The framework is run through the pl (short for please), plcd and plvi commands.
The pl command has been added to bash commands so can be accessed anywhere. It is followed by the script name and 
usually which instance to be worked on, eg "pl backup varc" will backup the 'varc' instance (varc is a varbase install using composer)
There is a yaml file which contains the framework setup (pl.yml). An example yaml file is provided and is ready to be used, with 
some tweaking required ('example.pl.yml' copy this file to pl.yml and tweak it).
You set pleasy up with the following commands

```
sudo apt update
cd $home
git clone https://github.com/mayostudio/pleasy.git
sudo bash ./pleasy/bin/pl  init
sudo source ~/.bashrc
pl update
```
Now edit pl.yml with your settings or just use the defaults

You will now have a functioning pleasy.

You should now be able to install your first site:
```
pl install d9
```
OR if you want to install the varbase distribution
```
pl install varc
```
You can then move around between sites using plcd
```angular2html
plcd d9 #Takes you to the root of the site
plcd d9 d #Takes you to the webroot of the site
plcd d9 t #Takes you to the default theme of the site
plcd d9 b #Takes you to the backups of the site
plcd d9 sd #Takes you to the sites/default folder of the site
plcd a #Takes you to /etc/apache2/sites-available
plcd b #Takes you to site backups
plcd l #Takes you to /usr/local/bin
plcd s #Takes you to pleasy scripts
plcd x #Takes you to /etc/nginx/sites-available
```

The infrastructure for each site is setup including a stage version, eg for d9 the stage version is stg_d9.
Once a production version is created (follow the instructions in the server script readme to set up the production site [readme](https://github.com/rjzaar/pleasy/blob/master/server/README.md)), both production and test sites are also created by the initserver script, ie prod_d9 and test_d9.

Here is the overview of all the possible locations using the d9 sitename as an example.

**d9**          the main dev site for d9 stored locally. Location: [www_path][sitename] Backup: [pleasy][sitebackups][sitename]

eg: Location "/var/www/oc/d9" backup "/home/[USER]/pleasy/sitebackups/d9" URL: pleasy.d9

**stg_d9**      the stage site for d9 stored locally.   Location: [www_path][sitename] Backup: [pleasy][sitebackups][sitename]

eg: Location "/var/www/oc/stg_d9" backup "/home/[USER]/pleasy/sitebackups/stg_d9" URL: pleasy.stg_d9

**prod_d9**     the production site for d9 on the server.

eg: Location "/var/www/[siteurl]" backup "/home/[USER]/[siteurl]/" URL: [siteurl]

**test_d9**     the test site for d9 on the server.

eg: Location "/var/www/test.[siteurl]" backup "/home/[USER]/test.[siteurl]/" URL: test.[siteurl]

**d9_prod**     This is just to store the production backup locally.

eg: There is no location. backup "/home/[USER]/pleasy/sitebackups/d9/prod/" There is no URL.

Drush also works. Each sitename becomes the alias. This can be accessed from anywhere.
```angular2html
drush @d9 status #runs the status command on the d9 site.
drush @stg_d9 status #runs the status command on the stage version of d9 site.
drush @prod_d9 status #runs the status commend on the production version of the d9 site, if there is a production version of the site.
drush @test_d9 status #runs the status commend on the test version of the loc site which is on the production server, if it is setup.
```
Drupal console aliases are also setup.

# Config: pl.yml

The main configuration is in a single file called pl.yml. This is created from the example.pl.yml file. pl.yml needs
to be edited to suit the current user, eg setting github credentials. But it has enough information to be useable 
out of the box. The following site information is ready to go

d9: Drupal 9 install

d9c: Drupal 9 composer install

varg: varbase-project install using git

vard: dev varbase-project install using composer

varc: varbase-project install using composer 

More specifically the following variables are set in pl.yml

hosts_path: "/etc/hosts"

vhosts_path: "/etc/apache2/sites-available/"

www_path: "/var/www/oc"

host_database: mysql

# VARBASE

It provides various scripts for development processes which incorporate composer, cmi and backup. Communication with the 
production server is via drush and git or scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.

A particular site based project needs to include site specific files which should be stored on a private 
repository for backup. 

# WORKFLOW

There are several ways to run the workflow. The simplest is via tar files.
Once you have a production server, eg vanilla ubuntu 20.04 server. You should follow the server readme
to setup the server. Once the server is setup you need to add your production server details to pl.yml. 
You will then be able to push up your site to the server, eg 'pl prodow stg_d9'. 'Prodow' stands for PRODuction OverWrite,

To pull down the site use 'pl proddown stg_d9' and this will download and install the site to stg_d9.


Opencourse (ocrepo): A repo for just the code for opencourse (dev environment)

Production site repo (prodrepo): A repo of all of the site files (prod environment) Master branch stores prod. Dev
branch stores the new prod to be pushed up.

Production database repo (prod.sql): A private secure repo for the live database (ocback).

The suggest best way to run workflow is explained in this presentation: 
https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
  at 29:36
  
This has been implemented with the following commands
Merge dev into master (or other branch)
```
pl gcom #will export config and commit to git
git pull # Check the pull works.
git merge master
pl runup #will run any updates. Check all is good.
git checkout master 
git merge dev #check for errors.
git push
git checkout dev # back to work
```
Process to push to production
```
pl proddown stg #copy prod to stg
pl gcom loc
pl dev2stg loc #will use git to move dev files to stg. stg has prodrepo.
pl runup stg #run updates on stage and check site.
```
You can repeat these steps to set up the live test site on the production server

```
pl updateprod stg_loc -td
```
And/or you can run them on the live production server.
```
pl updateprod # This repeats the steps on Prod. Check all is well.
```
If there is a problem on production.

```
pl restoreprod  #This restores Prod to the old site. Only if needed.
```
 
# BACKUP AND RESTORE

The backup command is able to backup any site to its sitebackup folder, eg /var/www/oc/d9 is backed up to 
/home/[USER]/[siteurl]/[backupname].sql and [backupname].tar.gz

The [backupname] is generated from the date, time, git hash code and backup message.

If the production site is backed up, it will be backed up on the server, ie pl backup prod_d9.
If the production site is backed up to prod, ie pl backup prod_d9 prod, then it will also be
stored locally in /home/[USER]/[siteurl]/prod/[backupname].sql location (including the tar 
file).

The restore command will restore the site from a chosen backup or to a new location. 


# PLEASY RATIONALE

What makes pleasy different? Pleasy is trying to use the simplest tools (bash scripting) to leverage drupal and varbase tools 
to provide the simplest and yet powerful devops environment. This way it is easy for beginners to adopt and even improve, yet
powerful enough to use for production. It tries to take the suggested best practice from Drupal documentation and turn it into
scripts. It hopes to grow into a complete devops solution incorporating the best tools and practices available. 

# ROADMAP

1) The varbase use of Phing to install the site needs to be integrated into pleasy.

2) The varbase script varbase-update.sh needs to be integrated into pleasy.

4) All the remaining scripts (ie with status todo) need to be updated and integrated.

5) All scripts tested with CircleCI

6) This will become a 1.0 release

7) Lando or docker integrated into pleasy using https://github.com/pendashteh/landrop. This will be a 2.0 release

8) New functions to set up site testing using varbase behat code.

9) Automatic CircleCI testing of any commits.

10) These new functions to set up CircleCI tests that respond to drupal core security updates automatically and if passing auto push to production.

11) New update functions to set up CircleCI tests that respond to varbase project updates, test automatically and create stage site which is tested automatically. One line code push to production.

Other improvements: Varnish as an option. Incorporate https://github.com/drevops/drevops



Status codes

pass: Working and passing CircleCI  ☑

works: Working but not yet integrated to Travis CI  👷

todo: Has not been looked at yet   ❓


# FUNCTION LIST
<details>

**<summary>addc: Add github credentials 👷 </summary>**
Usage: pl addc [OPTION]
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc 

</details>

<details>

**<summary>backupdb: [34mbackup --help [39m 👷 </summary>**
--**BROKEN DOCUMENTATION**--
Backs up the database only
    Usage: pl backupdb [OPTION] ... [SOURCE]
  This script is used to backup a particular site's database.
  You just need to state the sitename, eg dev.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
    -m --message='msg'      Enter an optional message to accompany the backup

  Examples:
  pl backupdb -h
  pl backupdb dev
  pl backupdb tim -m 'First tim backup'
  pl backupdb --message='Love' love
  END HELP
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>backup: Backup site and database ☑ </summary>**
Usage: pl backup [OPTION] ... [SOURCE] [MESSAGE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev and an optional message.
You can also optionally specify where the site will be backedup to. This is useful if you are backing up the production
site to a local location, instead of on the production server.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -g --git                Also create a git backup of site.
  -e --endpoint           The backup destination

Examples:
pl backup -h
pl backup dev 'Fixed error'
pl backup tim -e=fred 'First tim backup'

END HELP

</details>

<details>

**<summary>copyf: Copies only the files from one site to another 👷 </summary>**
Usage: pl copyf [OPTION] ... [SOURCE]
This script will copy one site to another site. It will copy only the files
but will set up the site settings. If no argument is given, it will copy dev
to stg If one argument is given it will copy dev to the site specified If two
arguments are give it will copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:

</details>

<details>

**<summary>copypt: Copy the production site to the test site. 👷 </summary>**
Usage: pl copypt [SITE] [OPTION]
  This script is used to copy the production site to the test site. The site
  details are in pl.yml.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl copypt loc

</details>

<details>

**<summary>copy: Copies one site to another site. ☑ </summary>**
    Usage: pl copy [OPTION] ... [SOURCE] [DESTINATION]
This script will copy one site to another site. It will copy all
files, set up the site settings and import the database.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:

</details>

<details>

**<summary>dev2stg: Uses git to update a stage site with the dev files. 👷 </summary>**
Usage: pl dev2stg [OPTION] ... [SOURCE]
This script will use git to update the files from the dev site to the stage
site, eg d9 to stg_d9. If one argument is given it will copy the site specified to the stage site. If two arguments are
give it will copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -d --debug              Provide debug information when running this script.

Examples:
pl dev2stg d9
pl dev2stg d9 t1

</details>

<details>

**<summary>doctest: Add github credentials 👷 </summary>**
Usage: pl addc [OPTION]
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc 

</details>

<details>

**<summary>enmod: Usage: pl enmod [OPTION] ... [SITE] [MODULE] 👷 </summary>**
--**BROKEN DOCUMENTATION**--
This script will install a module first using composer, then fix the file/dir
ownership and then enable the module using drush automatically.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>fixp: Usage: pl fixp [OPTION] ... [SOURCE] 👷 </summary>**
--**BROKEN DOCUMENTATION**--
This script is used to fix permissions of a Drupal site You just need to
state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>fixss: Usage: pl fixss [OPTION] ... [SOURCE] 👷 </summary>**
--**BROKEN DOCUMENTATION**--
This will fix (or set) the site settings in local.settings.php You just need
to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>gcom: args:  --help -- 👷 </summary>**
--**BROKEN DOCUMENTATION**--
Git commit code with optional backup
Usage: pl gcom [SITE] [MESSAGE] [OPTION]
This script will export config and git commit changes to [SITE] with [MESSAGE].\
If you have access rights, you can commit changes to pleasy itself by using pl
for [SITE] or pleasy.

OPTIONS
  -h --help               Display help (Currently displayed)
  -b --backup             Backup site after commit
  -v --verbose            Provide messages of what is happening
  -d --debug              Provide messages to help with debugging this function

Examples:
pl gcom loc "Fixed error on blah." -bv\
pl gcom pl "Improved gcom."
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>gcomvup: Git commit and update to latest varbase stable ❓ </summary>**
Usage: pl  [OPTION] ... [SITE] [MESSAGE]
Varbase update, git commit changes and backup. This script follows the
correct path to git commit changes You just need to state the
sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl  -h
pl  dev (relative dev folder)
pl  tim 'First tim backup'
END HELP

</details>

<details>

**<summary>gulp: Turn on gulp 👷 </summary>**
Usage: pl  [OPTION] ... [SITE] [URL]
This script is used to set up gulp browser sync for a particular page. You
just need to state the sitename and optionally a particular page
, eg loc and http://pleasy.loc/sar

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl  loc
pl  loc http://pleasy.loc/sar

END HELP

</details>

<details>

**<summary>info: Information on site(s) ☑ </summary>**
Usage: pl info [SITE] [TYPE] [OPTION]
This script is used to provide various information about a site.
You just need to state the sitename, eg dev and optionally the type of information

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl info -h
pl info dev
END HELP

</details>

<details>

**<summary>init: Initialises pleasy ☑ </summary>**
  Usage: pl init [OPTION]
This will set up pleasy and initialise the sites as per
pl.yml, including the current production shared database.
This will install many programs, which will be listed at
the end.

Mandatory arguments to long options are mandatory for short options too.
    -y --yes                Force all install options to yes (Recommended)
    -h --help               Display help (Currently displayed)
    -s --step={1,15}        FOR DEBUG USE, start at step number as seen in code
    -n --nopassword         Nopassword. This will give the user full sudo access without requireing a password!
                            This could be a security issue for some setups. Use with caution!
    -t --test            This option is only for test environments like Travis, eg there is no mysql root password.

Examples:
git clone git@github.com:rjzaar/pleasy.git [sitename]  #eg git clone git@github.com:rjzaar/pleasy.git mysite.org
bash ./pleasy/bin/pl  init # or if using [sitename]
bash ./[sitename]/bin/pl init

then if debugging:

bash ./[sitename]/bin/pl init -s=6  # to start at step 6.

INSTALL LIST:
    sudo apt-get install gawk
    sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath\/bin" $user
    sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli \
    php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip
    php-xdebug -y
    sudo apt-get -y install mysql-server
    sudo apt-get install phpmyadmin -y
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    curl https://drupalconsole.com/installer -L -o drupal.phar
    sudo apt install nodejs build-essential
    curl -L https://npmjs.com/install.sh | sh
    sudo apt install npm
    sudo npm install gulp-cli -g
    sudo npm install gulp -D
END OF HELP

</details>

<details>

**<summary>install: Installs a drupal site ☑ </summary>**
Usage: pl install site [OPTION]
This script is used to install a variety of drupal flavours particularly
opencourse This will use opencourse-project as a wrapper. It is presumed you
have already cloned opencourse-project.  You just need to specify the site name
as a single argument.  All the settings for that site are in pl.yml If no site
name is given then the default site is created.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -f --files              Only install site files. No database
  -s --step=[INT]         Restart at the step specified.
  -b --build-step=[INT]   Restart the build at step specified (step=6)
  -d --debug              Provide debug information when running this script.
  -t --test               This option is only for test environments like Travis, eg there is no mysql root password.
  -e --extras             Install extra features like yarn and bower

Examples:
pl install d8
pl install ins -b=6 #To start from installing the modules.
pl install loc -s=3 #start from composer install
END HELP

</details>

<details>

**<summary>main: Turn maintenance mode on or off 👷 </summary>**
Usage: pl main [OPTION] ... [SITE] [MODULES]
This script will turn maintenance mode on or off. You will need to specify the
site first than on or off, eg pl main loc on

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl main loc on
pl main dev off
END HELP

</details>

<details>

**<summary>makedb: Create the database for a site 👷 </summary>**
Usage: pl makedb [OPTION] ... [SITE]
<ADD DESC HERE>

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide messages to help with debugging this function

Examples:
END HELP

</details>

<details>

**<summary>makedev: Turn dev mode on for a site ☑ </summary>**
Usage: pl  [OPTION] ... [SITE]
This script is used to turn on dev mode and enable dev modules.
You just need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl makedev loc
END HELP

</details>

<details>

**<summary>makeprod: Turn production mode on and remove dev modules ☑ </summary>**
Usage: pl makeprod [OPTION] ... [SITE]
This script is used to turn off dev mode and uninstall dev modules.  You just
need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
END HELP

</details>

<details>

**<summary>open: Opens the specified site 👷 </summary>**
Usage: pl open [OPTION] ... [SOURCE]
This script will open the specified site.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl open loc

</details>

<details>

**<summary>proddownold: Overwrite the stage site with production 👷 </summary>**
Usage: pl proddown [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: If the local site will be deleted if it already exists.
Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function
  -y --yes                Answer yes to all prompts


Examples:
pl proddown stg_d9
pl proddown stg_d9 -s=2
END HELP

</details>

<details>

**<summary>proddownr: Overwrite the stage site with production 👷 </summary>**
Usage: pl proddownr [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: The local site will be deleted if it already exists.
Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function
  -y --yes                Answer yes to all prompts


Examples:
pl proddownr stg_d9
pl proddownr stg_d9 -s=2
END HELP

</details>

<details>

**<summary>proddownt: Overwrite the stage site with production using tar 👷 </summary>**
Usage: pl proddownt [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. Note: If the local site will be deleted if it already exists.
Production will be downloaded to stg_[SITE]. The external site details are set in pl.yml under 'prod:'.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function
  -y --yes                Answer yes to all prompts


Examples:
pl proddownt stg_d9
pl proddownt stg_d9 -s=2
END HELP

</details>

<details>

**<summary>prodowgit: Overwrite production with site specified ❓ </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl prodow stg
END HELP

</details>

<details>

**<summary>prodow: Overwrite production with site specified ❓ </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl prodow stg
END HELP

</details>

<details>

**<summary>prodowtar: Overwrite production with site specified ❓ </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl prodowtar stg
END HELP

</details>

<details>

**<summary>prodstat: Production status 👷 </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will provide the status of the production site

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl prodstat
END HELP

</details>

<details>

**<summary>rebuild: Rebuild a site's database ❓ </summary>**
Usage: pl rebuild [OPTION] ... [SITE]
This script is used to rebuild a particular site's database. You just need to
state the sitename, eg loc.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP

</details>

<details>

**<summary>recreateserverdb: Recreate the server Database ❓ </summary>**
Usage: pl createserverdb [OPTION] ... [SITE]

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options

Examples:
pl recreateserverdb loc
END HELP

</details>

<details>

**<summary>restoredb: Restore a particular site's  database. 👷 </summary>**
--**BROKEN DOCUMENTATION**--
You just need to state the sitename, eg d9.
You can alternatively restore the site into a different site which is the second argument.

Usage: pl  [OPTION] ... [SITE] [MESSAGE]

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl  d9 # This will restore the db on the d8 site.
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>restore: Restore a particular site's files and database from backup ☑ </summary>**
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.
If the [FROM] site is prod, and the production method is git, git will be used to restore production

OPTIONS
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -s --step=[INT]         Restart at the step specified.
  -f --first              Use the latest backup
  -y --yes                Auto delete current content

Examples:
pl restore d9
pl restore d9 stg_d9 -fy
pl restore -h
pl restore d9 -d
pl restore d9_prod stg_d9

</details>

<details>

**<summary>runup: This script will run any updates on the stg site or the site specified. 👷 </summary>**
Usage: pl runupdates [OPTION] ... [SOURCE]
This script presumes the files including composer.json have been updated in some way and will now run those updates.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl runup loc
pl runup test # This will run the updates on the external test server.

</details>

<details>

**<summary>stopgulp: This script is used to kill any processes started by gulp. There are no arguments required. 👷 </summary>**
--**BROKEN DOCUMENTATION**--

--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>testserver: Test the production server initialisation ❓ </summary>**
Usage: pl testserver [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl testserver stg
END HELP

</details>

<details>

**<summary>testsite: Overwrite production with site specified ❓ </summary>**
Usage: pl testsite [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl testsite stg
END HELP

</details>

<details>

**<summary>unmod: Usage: pl unmod [OPTION] ... [SITE] [MODULE] 👷 </summary>**
--**BROKEN DOCUMENTATION**--
This script will uninstall a module first using drush then composer.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl unmod cat migrate_plus
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>updateprod: Update Production (or test) server with the specified site. 👷 </summary>**
Usage: pl  [OPTION] ... [SITE]
This will copy the site specified to the production (or test) server and run
the updates on that server.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -t --test               Update the test server not production.

Examples:
pl  d9 # This will update production with the d9 site.
pl  d9 -t # This will update the test site specified in pl.yml with the d9 site.

</details>

<details>

**<summary>updateserver: Update Production Server Scripts. 👷 </summary>**
Usage: pl  [OPTION] ... [SITE] [MESSAGE]

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl  d8 # This will update production with the d8 site.

</details>

<details>

**<summary>update: Update all site configs ☑ </summary>**
Usage: pl update [OPTION]
This script will update the configs for all sites

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:

</details>

<details>

**<summary>updatestg: Update stg or specified site. 👷 </summary>**
Usage: pl  [OPTION] ... [SITE] [MESSAGE]
This will run the updates on stg or specified site.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -t --test               Update the test server not production.

Examples:
pl  d8 # This will update the d8 stg site with the code in d8.
pl  d8 stg_t3 # This is update the stg_t3 site with the code in d8.

</details>

<details>

**<summary>test:  ❓ </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>varup:  ❓ </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

