# .bash_profile
# Author:  Jesse Butryn <jesse.butryn>
#
#####################################
# Table of Contents
#####################################
#
# 1) Colors
# 2) Begin
# 3) Environmental Variables
# 4) Information
# 5) Other
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
TXT_GOOD="${TXT_BLD}${TXT_GRN}"
TXT_WARN="${TXT_BLD}${TXT_YLW}"
TXT_FAIL="${TXT_BLD}${TXT_RED}"
TXT_RST=$(tput sgr0)
#####################################
# Section 2: Begin
#####################################
clear
echo -e "==========Loading ${TXT_GOOD}bash_profile${TXT_RST}=========="
[[ $PRIVATERC_RUN != yes && -f ~/.privaterc ]] && source ~/.privaterc
[[ -f ~/.bashrc ]] && source ~/.bashrc
#####################################
# Section 3: Environmental Variables
#####################################
### SYSTEM ###
export NVM_DIR=/Users/jessebutryn/.nvm
export EXTERNAL_IP=$(curl --connect-timeout 2 -m 5 -Ss ipinfo.io/ip)
export CURR_SSID=$(airport -I | awk -F: '$1 ~ /\sSSID/{gsub(/\s+/, ""); print $2}')
export CURR_DAY=$(date +%a)
### PERSONAL ###
export SSH_INPUT='/Users/jessebutryn/tools/.nodeinput.csv'
case $CURR_SSID in
	Joyent5) export MAC_LOCATION=work;;
	ITBurnsWhenIP5)	export MAC_LOCATION=home;;
	*)	export MAC_LOCATION=other;;
esac
#####################################
# Section 4: Information
#####################################
case $MAC_LOCATION in
	work)
		curl --connect-timeout 2 -m 5 -Ss "wttr.in/80127" | tail -n +2 | head -n 6
		echo -e "\t${TXT_WARN}Littleton, CO${TXT_RST}\n"
		echo -e "Location:\t${TXT_FAIL}WORK${TXT_RST} | Hostname:\t${TXT_BLD}$(hostname)${TXT_RST} | Date:\t${TXT_BLD}$(date "+%m/%d/%Y %H:%M")${TXT_RST}" | column -t
	;;
	home)
		curl --connect-timeout 5 -m 15 -Ss "wttr.in/80123" | tail -n +2 | head -n 6
		echo -e "\t${TXT_GOOD}Littleton, CO${TXT_RST}\n"
		echo -e "Location:\t${TXT_GOOD}HOME${TXT_RST} | Hostname:\t${TXT_BLD}$(hostname)${TXT_RST} | Date:\t${TXT_BLD}$(date "+%m/%d/%Y %H:%M")${TXT_RST}" | column -t
	;;
	*)	echo -e "${TXT_FAIL}Where the hell are you?${TXT_RST}";;
esac
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
case $CURR_DAY in
	Sun|Mon|Tue)	
		printf '%40s:\n%65s\n' "$(date +%A)" "${TXT_FAIL}Don't work on your day off.${TXT_RST}"
		printf '%s\n' "${TXT_BLD}$(skookumq)${TXT_RST}"
	;;
	Wed)
		printf '%40s:\n%62s\n' 'Wednesday' "${TXT_FAIL}Oh shit...just starting${TXT_RST}"
		printf '%s\n' "${TXT_BLD}$(skookumq)${TXT_RST}"
	;;
	Thu)
		printf '%40s:\n%68s\n' 'Thursday' "${TXT_WARN}Everything will break today, bet.${TXT_RST}"
		printf '%s\n' "${TXT_BLD}$(skookumq)${TXT_RST}"
	;;
	Fri)
		printf '%40s:\n%65s\n' 'Friday' "${TXT_WARN}Almost there...wtf is node.js?${TXT_RST}"
		printf '%s\n' "${TXT_BLD}$(skookumq)${TXT_RST}"
	;;
	Sat)
		printf '%40s:\n%72s\n' 'Saturday' "${TXT_GOOD}This is it...don't burn the place down!${TXT_RST}"
		printf '%s\n' "${TXT_BLD}$(skookumq)${TXT_RST}"
	;;
esac
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
echo "History on today's date:"
awk -v td="$(date '+%m/%d')" '$1 == td' /usr/share/calendar/calendar.history
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
printf 'Network: %s\t|\tChannel: %s\t|\tExternal IP: %s\n' \
	"${TXT_WARN}$CURR_SSID${TXT_RST}" \
	"${TXT_BLD}$(airport -I | awk '/channel/{print $NF}')${TXT_RST}" \
	"${TXT_BLD}$EXTERNAL_IP${TXT_RST}"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" | tr ' ' .
