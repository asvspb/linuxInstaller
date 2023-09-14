#!/bin/bash

set -e

echo " "
echo "Настройка паролей"
echo "--------------------------------------------------------------"
# чтоб не спрашивал пароль при sudo
sudo bash -c 'echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd'

# чтоб не ждал подтверждения при установке
export DEBIAN_FRONTEND=noninteractive
if [ -f /etc/needrestart/needrestart.conf ]; then
  sudo sed -i '/\$nrconf{restart}/s/^#//g' /etc/needrestart/needrestart.conf
  sudo sed -i "/nrconf{restart}/s/'i'/'a'/g" /etc/needrestart/needrestart.conf
else
  sudo mkdir -p /etc/needrestart
  echo '$nrconf{restart}' = \'a\'';' > nrconf
  sudo cp nrconf /etc/needrestart/needrestart.conf
  rm nrconf
fi

# чтоб не спрашивал authenticity of host gitlab.com
mkdir -p ~/.ssh
chmod 0700 ~/.ssh
echo -e "Host gitlab.com\n   StrictHostKeyChecking no\n   UserKnownHostsFile=/dev/null" > ~/.ssh/config

echo " "
echo "Установка времени"
echo "--------------------------------------------------------------"
sudo timedatectl set-local-rtc 1 --adjust-system-clock 
sudo timedatectl

echo "                                                              "
echo "Устанавливаем системные приложения"
echo "--------------------------------------------------------------"
sudo apt update -y
sudo apt-get install git gh mc tmux zsh mosh curl wget ca-certificates net-tools -y
sudo apt install gnome-shell-extensions gnome-tweaks ubuntu-restricted-extras software-properties-common -y

echo "                                                              "
echo "Установка telegram"
echo "--------------------------------------------------------------"
snap install telegram-desktop

echo "                                                              "
echo "Установка Chrome"
echo "--------------------------------------------------------------"
cd $HOME/Downloads
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb &&
sudo dpkg -i google-chrome-stable_current_amd64.deb &&
rm -f google-chrome-stable_current_amd64.deb

sudo apt -f install

echo "                                                              "
echo "Установка завершена!"
echo "--------------------------------------------------------------"
