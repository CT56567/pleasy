sudo apt update
sudo apt upgrade -y
cd $home
git clone https://github.com/mayostudio/pleasy.git
sudo bash ./pleasy/bin/pl init
sudo echo "PATH=$Path:$home/pleasy/bin" >> ~/.bashrc 
pl update
