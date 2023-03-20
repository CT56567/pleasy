sudo apt update
sudo apt upgrade -y
cd $home
git clone https://github.com/mayostudio/pleasy.git
sudo bash ./pleasy/bin/pl init
sudo source ~/.bashrc
pl update
