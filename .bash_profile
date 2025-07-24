# .bash_profile
# Author:  Jesse Butryn <jesse.butryn>
#
#####################################
# Section 1: Colors
#####################################
TXT_BLD=$(tput bold)
TXT_RED=$(tput setaf 1)
TXT_GRN=$(tput setaf 2)
TXT_YLW=$(tput setaf 3)
TXT_BLU=$(tput setaf 4)
TXT_MAG=$(tput setaf 5)
TXT_CYN=$(tput setaf 6)
TXT_WHT=$(tput setaf 7)
TXT_GOOD="${TXT_BLD}${TXT_GRN}"
TXT_WARN="${TXT_BLD}${TXT_YLW}"
TXT_FAIL="${TXT_BLD}${TXT_RED}"
TXT_RST=$(tput sgr0)
#####################################
# Section 2: Begin
#####################################
clear
echo -e "==========Loading ${TXT_GOOD}bash_profile${TXT_RST}=========="
#####################################
# Section 3: Environmental Variables
#####################################
### SYSTEM ###
export EXTERNAL_IP=$(curl --connect-timeout 2 -m 5 -Ss ipinfo.io/ip)
export CURR_SSID=$(iwgetid -r)
export CURR_DAY=$(date +%a)
#####################################
# Section 4: Information
#####################################
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
printf 'Network: %s\t|\tExternal IP: %s\n' \
	"${TXT_WARN}$CURR_SSID${TXT_RST}" \
	"${TXT_BLD}$EXTERNAL_IP${TXT_RST}"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
#####################################
# Section 5: Load bashrc
#####################################
if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi