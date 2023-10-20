#! /bin/bash

set -e

echo " "
echo "Установка репозиториев"
echo "--------------------------------------------------------------"
sudo add-apt-repository ppa:thopiekar/openrgb
sudo add-apt-repository ppa:trebelnik-stefina/grub-customizer
sudo add-apt-repository ppa:ubuntuhandbook1/rhythmbox
sudo add-apt-repository -y ppa:deadsnakes/ppa

echo " "
echo "Установка ключей"
echo "--------------------------------------------------------------"
sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

#gsmartcontrol
echo 'deb http://download.opensuse.org/repositories/home:/alex_sh:/gsmartcontrol:/stable_latest/xUbuntu_21.10/ /' | sudo tee /etc/apt/sources.list.d/home:alex_sh:gsmartcontrol:stable_latest.list
curl -fsSL https://download.opensuse.org/repositories/home:alex_sh:gsmartcontrol:stable_latest/xUbuntu_21.10/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_alex_sh_gsmartcontrol_stable_latest.gpg > /dev/null

#thorium
wget https://dl.thorium.rocks/debian/dists/stable/thorium.list
sudo mv thorium.list /etc/apt/sources.list.d/

# установка syncthing
type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null 

echo " "
echo "Установка окружения для программиирования"
echo "--------------------------------------------------------------"
sudo apt update -y

echo "                                                              "
echo "Установка Vscode"
echo "--------------------------------------------------------------"

#vscode
wget -O- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee /usr/share/keyrings/vscode.gpg
echo deb [arch=amd64 signed-by=/usr/share/keyrings/vscode.gpg] https://packages.microsoft.com/repos/vscode stable main | sudo tee /etc/apt/sources.list.d/vscode.list

# устанавливаем nvm + node
nvm_version=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep -oP '"tag_name": "\K.*?(?=")')
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh" | bash
source ~/.nvm/nvm.sh 	# инициализация
source ~/.bashrc 	# перезапуск оболочки
npm install -g npm@latest
nvm install node

# установка python java
sudo apt install code gcc python3 python3-pip python3-venv python3-tk pythonpy python3.10 python3.11 python3.12 default-jdk -y
# закрепляем версию 3.11 питона в системе
sudo ln -s /usr/bin/python3.11 /usr/bin/python

node_version=$(node -v)
python_version=$(python3 --version 2>&1)
echo "--------------------------------------------------------------"
echo "node установлен версии - $node_version"
echo "python установлен версии - $python_version"
echo "--------------------------------------------------------------"

# установка системных пакетов
sudo apt install btop iftop htop neofetch rpm wireguard jq guake copyq syncthing thorium-browser -y
sudo apt install inxi cpu-x tldr fzf rhythmbox vlc alacarte qbittorrent speedtest speedtest-cli software-properties-common  -y
sudo apt install grub-customizer gparted gsmartcontrol synaptic openrgb ufw timeshift nala  -y

#запуск syncthing
echo " "
echo "Запуск syncthing"
echo "--------------------------------------------------------------"
sudo systemctl start syncthing@$USER
sudo systemctl enable syncthing@$USER

echo " "
echo "Установка системных приложений snap"
echo "--------------------------------------------------------------"
# Путь к файлу, в котором сохранен список пакетов snap
PACKAGE_FILE="ubuntu_snap_packages.txt"

# Чтение файла и установка пакетов, если они отсутствуют в системе
while IFS= read -r package; do
  if ! snap list "$package" 2>/dev/null | grep -q "$package"; then
    echo "Установка пакета $package..."
    sudo snap install "$package"
  else
    echo "Пакет $package уже установлен."
  fi
done < "$PACKAGE_FILE"

sudo snap install obsidian --classic
sudo snap install gitkraken --classic
sudo snap install tribler-bittorrent --beta

echo " "
echo "Установка wireguard"
echo "--------------------------------------------------------------"
# Путь к файлу конфигурации WireGuard
wg_conf="/etc/wireguard/wg0.conf"
sudo touch "$wg_conf"

sudo chmod 0600 /etc/wireguard/wg0.conf
sudo systemctl start wg-quick@wg0.service
sudo ln -sf /usr/bin/resolvectl /usr/local/bin/resolvconf

# сворачивание приложение по клику в доке
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'


echo "--------------------------------------------------------------"
echo "Установка завершена успешно"
echo "--------------------------------------------------------------"
