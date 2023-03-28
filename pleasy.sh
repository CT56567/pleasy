sudo apt update
sudo apt upgrade -y
cd $home
git clone https://github.com/mayostudio/pleasy.git
sudo bash ./pleasy/bin/pl init
sudo echo "export PATH=$home/pleasy/bin/:$PATH" >> $home/.bashrc 
