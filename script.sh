#!/bin/bash

#My favorite first linux command
sudo ufw enable

sudo apt install bum

echo "changing file settings"
#Standard files edits for safer settings
sudo sed -i '/^net.ipv4.tcp_syncookies/d' /etc/sysctl.conf && echo "net.ipv4.tcp_syncookies=1" | sudo tee -a /etc/sysctl.conf
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   30/' /etc/login.defs
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/' /etc/login.defs

#grub and shadow safe settings
sudo chmod /etc/shadow 600
sudo chmod /boot/grub/grub.cfg 644

#Media files
echo "Deleting media files"
find /home -type f \( -iname "*.mp3" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.flac"\) -delete

#Pass change
echo "Changing all passwords to safer ones"
NEW_PASS="Cyberpat2025!"
CURRENT_USER=$(whoami)
for user in $(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd); do
    if [ "$user" != "$CURRENT_USER" ]; then
        echo "Changing password for: $user"
        echo "$user:$NEW_PASS" | sudo chpasswd
        echo "Changed password for $user"
    else
        echo "Skipping current user: $CURRENT_USER"
    fi
done
echo "All passwords changed"

#Games
echo "removing games"
GAMES=(
    "gnome-games"
    "kde-games"
    "aisleriot"
    "gnome-mahjongg"
    "gnome-mines"
    "gnome-sudoku"
    "gnome-tetravex"
    "quadrapassel"
    "swell-foop"
    "lightsoff"
    "gnome-robots"
    "gnome-nibbles"
    "gnome-taquin"
    "five-or-more"
    "four-in-a-row"
    "hitori"
    "iagno"
    "tali"
    "sol"
    "freecell"
    "kpat"
    "kmahjongg"
    "kmines"
    "kolf"
    "konquest"
    "steam"
    "playonlinux"
)

for game in "${GAMES[@]}"; do
    if dpkg -l | grep -q "^ii.*$game"; then
        echo "Removing $game..."
        sudo apt-get remove -y "$game"
    fi
done

sudo apt-get autoremove -y

sudo find /usr/games /usr/local/games -type f -delete 2>/dev/null

#disable port sharing
echo "Trying to disable port sharing"
sudo systemctl stop smbd
sudo systemctl disable smbd
sudo systemctl stop nmbd
sudo systemctl disable nmbd

#security updates
echo "Periodic security updates"
sudo apt-get update
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

echo "Finally update everything"
sudo apt update
sudo apt upgrade
