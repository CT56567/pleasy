#!/bin/bash

# user is the new user for the production server
# pword is the password for the user on the production server
# key is the name of the ssh key for the production server that is on the dev machine
# ip is the ip address of the production server
# url is the site url that will be served on the production server
# email is the email address for the admin role on the server.
#       This is needed for certbot to generate the ssl certificate on the server

user="me"
pword='secret - shh - password'
key="rsa"
ip="777.777.777.777"
url="mysite.org"
email="admin@$url"