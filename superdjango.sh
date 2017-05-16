setxkbmap fi
sudo apt-get update
sudo apt-get -y install git puppet
git clone https://github.com/ibiuman/djangopuppet
cd django1
bash djangomodule.sh
echo Did It
