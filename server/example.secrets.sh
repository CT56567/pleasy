#!/bin/bash

# user is the new user for the production server
# pword is the password for the user on the production server
# key is the name of the ssh key for the production server that is on the dev machine
# ip is found automatically.
# url is the site url that will be served on the production server
# email is the email address for the admin role on the server.
#       This is needed for certbot to generate the ssl certificate on the server
# cont is to indicate if this is a container or not. Change this to "y" if this is going to be a container.

user="carlo"
pword='acutis'
key="bible"
url="gospel.org"
email="admin@$url"
prod_docroot="var/www/$url/docroot" # This is only needed for the initial first site setup. It is ignored later, since
  # prod_docroot is passed via variable ($1) and prod_docroot=$1 after ./secrets.sh is called.
prod_key="gitkey"
cont="n"
server_timezone="Australia/Melbourne"

export user
