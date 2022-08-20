This folder contains the scripts for the server setup.

The server needs to be setup according to the following steps
The server scripts runs the commands in these tutorials for you.

https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04
https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-20-04
https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-20-04
https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04
https://www.howtoforge.com/tutorial/debian-nginx-drupal/


STEPS

1) set up ssh keys for root. (Linode has this as an option when setting up a new linode)
2) make sure you have .ssh/config set up correctly and pl.yml. then run pl updateserver [site-root user] # this pushes 
the scripts up.
3) change example.secrets.sh to secrets.sh and edit it on the server as root.
4) run initserverroot.sh as root and copy secrets.sh to your user. run pl updateserver [site] 
5) then ssh in as your normal user and run initserver.sh 
6) run prodow (which calls createsites.sh) from your dev machine. This will push up your local version to production
and set up all that is necessary for the site to be live.



todo: Use Lando locally as test site for scripts.
