#Set users to user
echo "Changing everyone to correct user admin confiuration"
USERS=(
  ""
)

ADMINS=(
  ""
)

for usr in "${USERS[@]}"; do
  sudo gpasswd -d "$usr" sudo
  sudo gpasswd -d "$usr" admin
done

for ad in "${ADMINS[@]}"; do
  sudo usermod -aG sudo $ad
  sudo usermod -aG admin $ad
done 

# Remove apps
WAR_NING = "TAKE NECESSARY APPS OUT OF THIS LIST"
echo "Removing random apps" 
APPS=(
    "wireshark"
    "wireshark-common"
    "tshark"
    "nmap"
    "netcat"
    "netcat-traditional"
    "nc"
    "telnet"
    "tcpdump"
    "john"
    "john-data"
    "hydra"
    "hydra-gtk"
    "aircrack-ng"
    "nikto"
    "sqlmap"
    "metasploit-framework"
    "burpsuite"
    "ettercap"
    "ettercap-graphical"
    "snort"
    "kismet"
    "ophcrack"
    "medusa"
    "p0f"
    "dsniff"
    "bleachbit"  # Linux equivalent of CCleaner
)

for app in "${APPS[@]}"; do
    if dpkg -l | grep -q "^ii.*$app"; then
        echo "Removing $app..."
        sudo apt-get remove --purge -y "$app"
    fi
done

sudo apt-get autoremove -y
sudo apt-get autoclean

#Virus check 
echo "Virus check"
echo "Installing/updating antivirus tools..."
sudo apt-get update
sudo apt-get install -y clamav clamav-daemon rkhunter chkrootkit

echo "Updating virus definitions..."
sudo systemctl stop clamav-freshclam
sudo freshclam
sudo systemctl start clamav-freshclam
sudo rkhunter --update

echo "Running ClamAV scan..."
sudo clamscan -r -i --log=/var/log/clamav-scan.log /home /tmp /var/tmp /root

echo "Running rootkit scan..."
sudo rkhunter --check --sk | tee /var/log/rkhunter-scan.log

echo "Running chkrootkit..."
sudo chkrootkit | tee /var/log/chkrootkit-scan.log

echo "Scans complete. Check logs at:"
echo "  /var/log/clamav-scan.log"
echo "  /var/log/rkhunter-scan.log"
echo "  /var/log/chkrootkit-scan.log"

sleep 10 

#General insecurities
LOG_FILE="/var/log/security-audit-$(date +%Y%m%d-%H%M%S).log"

echo "Starting security audit..." | tee -a "$LOG_FILE"

echo "
=== 1. CHECKING USERS ===" | tee -a "$LOG_FILE"
awk -F: '$3 == 0 {print "WARNING: User with UID 0:", $1}' /etc/passwd | tee -a "$LOG_FILE"
sudo awk -F: '($2 == "" ) {print "WARNING: User with empty password:", $1}' /etc/shadow | tee -a "$LOG_FILE"

echo "
=== 2. CHECKING SSH ===" | tee -a "$LOG_FILE"
sudo grep -E "PermitRootLogin|PasswordAuthentication|PermitEmptyPasswords" /etc/ssh/sshd_config | tee -a "$LOG_FILE"

echo "
=== 3. CHECKING LISTENING PORTS ===" | tee -a "$LOG_FILE"
sudo netstat -tulpn | tee -a "$LOG_FILE"

echo "
=== 4. CHECKING CRON JOBS ===" | tee -a "$LOG_FILE"
for user in $(cut -f1 -d: /etc/passwd); do
    cron_output=$(sudo crontab -u $user -l 2>/dev/null)
    if [ ! -z "$cron_output" ]; then
        echo "Cron for $user:" | tee -a "$LOG_FILE"
        echo "$cron_output" | tee -a "$LOG_FILE"
    fi
done

echo "
=== 5. CHECKING SUID/SGID FILES ===" | tee -a "$LOG_FILE"
sudo find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | tee -a "$LOG_FILE"

echo "
=== 6. CHECKING WORLD-WRITABLE FILES ===" | tee -a "$LOG_FILE"
sudo find / -xdev -type f -perm -0002 2>/dev/null | grep -v '/proc\|/sys' | tee -a "$LOG_FILE"

echo "
=== 7. CHECKING RECENT FILE MODIFICATIONS ===" | tee -a "$LOG_FILE"
sudo find /etc /bin /sbin -type f -mtime -7 2>/dev/null | tee -a "$LOG_FILE"

echo "
Audit complete. Full log saved to: $LOG_FILE"
