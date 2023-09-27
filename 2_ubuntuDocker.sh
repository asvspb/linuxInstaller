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
echo "Предварительное удаление старых версий докер"
echo "--------------------------------------------------------------"
# удаляем всё ненужное
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done


echo " "
echo "Установка докер"
echo "--------------------------------------------------------------"
sudo apt install -y curl wget gpg gnupg 

# добавляем ключ для докера
sudo rm -f /etc/apt/keyrings/docker.gpg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# добавляем докеровский реп
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "                                                              "
echo "Установка Vscode и всё что нужно для работы"
echo "--------------------------------------------------------------"
#vscode
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list

# устанавливаем всё что нужно для работы
# nvm + node
latest_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K.*?(?=")')
node_version=$(node -v)
python_version=$(python3 --version 2>&1)
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$latest_version/install.sh" | bash
source ~/.bashrc
nvm install node

# пакеты для программирования
sudo apt update
yes | sudo apt install code gh mc tmux zsh mosh wget make yarn apt-transport-https ca-certificates net-tools docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin gawk m4 libpcre3-dev libxerces-c-dev libspdlog-dev libuchardet-dev libssh-dev libssl-dev libsmbclient-dev libnfs-dev libneon27-dev libarchive-dev cmake g++ python3 python3-pip -y 
echo "node установлен версии - $node_versiom"
echo "nvm установлен версии - $latest_version"
echo "python установлен версии - $python_version"
echo "--------------------------------------------------------------"


echo " "
echo "Установка докер-композ"
echo "--------------------------------------------------------------"
# ставим Docker Compose
if [ ! -f /usr/local/bin/docker-compose ]; then
  sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-`uname -s`-`uname -m`" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

echo " "
echo "Установка far2l"
echo "--------------------------------------------------------------"
# ставим far2l
if [ ! -d ~/far2l ]; then
  cd
  rm -f ~/far2l || true
  git clone https://github.com/elfmz/far2l
  mkdir -p far2l/_build
  cd far2l/_build
  cmake -DUSEWX=no -DCMAKE_BUILD_TYPE=Release -DEACP=no -DPYTHON=no ..
  cmake --build . -j$(nproc --all)
  sudo cmake --install .
fi

echo " "
echo "Установка lazydocker"
echo "--------------------------------------------------------------"
# Get the latest version tag of Lazydocker release from GitHub
LAZYDOCKER_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
curl -Lo lazydocker.tar.gz "https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"

mkdir lazydocker-temp
tar xf lazydocker.tar.gz -C lazydocker-temp
sudo mv lazydocker-temp/lazydocker /usr/local/bin
rm -rf lazydocker.tar.gz lazydocker-temp
lazydocker --version


echo " "
echo "Создание папки Dev"
echo "--------------------------------------------------------------"
mkdir -p ~/Dev

echo " "
echo "Создание группы docker. Потребуется перезагрузка!"
echo "--------------------------------------------------------------"
sudo usermod -aG docker $USER
sudo systemctl start docker
sudo gpasswd -a $USER docker


echo '-------------------------------------------------------------------'
echo '---------------------- REBOOT IN 5 SEC ----------------------------'
echo '-------------------------------------------------------------------'
sleep 5
sudo reboot
