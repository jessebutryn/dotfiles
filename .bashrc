# .bashrc
# Author:  Jesse Butryn <jesse.butryn>
#
#set -x
###########################
# Start
###########################
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac
echo -e "=============Loading ${TXT_BLD}${TXT_BLU}bashrc${TXT_RST}============="
###########################
# History stuff
###########################
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000
###########################
# Shell options
###########################
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
###########################
# Functions
###########################
yorn_ask () {
	local _r
  	read -rp "$* [Y/n]: " _r
	until [[ ${_r,,} == y || ${_r,,} == n ]]; do
		printf '%s\n' "Please respond only with y or n"
		read -rp "$* [Y/n]: " _r
	done
	if [[ ${_r,,} == y ]]; then
		return 0
	else
		return 1
	fi
}
gitacp () {
	if [[ -z $1 ]]; then
		echo "ERROR! You must specify a file to add, commit, and push."
	else
		declare -a GIT_FILES+=("$@")
	fi
	for file in "${GIT_FILES[@]}"; do
		git add "$file" && continue
		echo "Failed to add $file"
	done
	git diff --stat --cached
	echo
	read -rp "What is your commit message? " GIT_COMMIT
	echo
	if ( git commit -m "$GIT_COMMIT" ); then
		git push || echo "Error! Failed to push."
	else
		echo "Error! Failed to commit."
	fi
}
weather () {
	local w_opts=
	local w_loc=
	while (( $# )); do
		case $1 in
			-a)
				local w_opts=ALL
			;;
			[0-9][0-9][0-9][0-9][0-9])
				local w_loc=$1
			;;
			*)
				echo "ERROR! Unknown option: $1"
				exit 1
			;;
		esac
		shift
	done
	if [[ "$w_opts" == ALL ]]; then
		curl -Ss "wttr.in/75422?u"
	else
		curl -Ss "wttr.in/75422?u" | tail -n +2 | head -n 6
	fi
}
parse_git_branch () {
  local branch
	branch=$(command git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')
	if [[ -n "$branch" && "$branch" == '(master)' ]] || [[ -n "$branch" && "$branch" == '(main)' ]]; then
		printf '%s' "${TXT_BLD}:${TXT_RST}${TXT_GOOD}${branch}${TXT_RST}"
	elif [[ -n "$branch" ]]; then
		printf '%s' "${TXT_BLD}:${TXT_RST}${TXT_FAIL}${branch}${TXT_RST}"
	fi
}
my.prompt () {
	local prompt=$1
	local open="\[${TXT_GOOD}\][\[${TXT_RST}\]"
	local close="\[${TXT_GOOD}\]]\[${TXT_RST}\]"
	local col="\[${TXT_BLD}\]:\[${TXT_RST}\]"
	case $prompt in
		simple)
			export PS1="\u \W \\$ "
		;;
		default)
			export PS1="\[${TXT_BLD}\]{\[${TXT_RST}\]\[${TXT_WARN}\]\$?\[${TXT_RST}\]\[${TXT_BLD}\]}\[${TXT_RST}\]${col}${open}${TXT_WHT}\w${TXT_RST}${close}${col}${open}\[${TXT_CYN}\]\$(TZ=UTC date '+%FT%TZ')\[${TXT_RST}\]${close}\$(parse_git_branch)\n\[${TXT_FAIL}\]\$ \[${TXT_RST}\]"
		;;
		nocolor)
			export PS1="[\w]:{\$?}\n\\$ \[$(tput sgr0)\]"
		;;
		ss)
			export PS1="\\$ "
		;;
		*)
			export PS1='\h:\W \u\$ '
		;;
	esac
}
dict () {
	less < <(
		curl -s "dict://dict.org/d:$@" \
		| egrep -v '^220|^221|^250|^150' \
		| sed $'s/^151/-------------------------------\\\n/g'
		)
}
ascii () {
	while (( $# )); do
		case $1 in
			fliptable)
				printf '%s' '(╯°□°）╯︵ ┻━┻' | pbcopy
				pbpaste && echo
			;;
			unfliptable)
				printf '%s' '┬─┬ノ( º _ ºノ)' | pbcopy
				pbpaste && echo
			;;
			shrug)
				printf '%s' '¯\_(ツ)_/¯' | pbcopy
				pbpaste && echo
			;;
			*)
				echo "Unsupported argument"
			;;
		esac
		shift
	done
}
noformatize () {
	printf '%s\n' '{noformat}' "$(pbpaste)" '{noformat}' | pbcopy
	[[ $1 == '-v' ]] && pbpaste
	return 0
}
mmcode () {
	local lang=$1
	printf '%s\n' "\`\`\`$lang" "$(pbpaste)" '```' | pbcopy
}
tableize () {
	local delim
	local content
	content=$(pbpaste)
	if [[ -n $1 ]]; then
		delim=$1
	else
		delim=' '
	fi
	awk -F"$delim" 'BEGIN{OFS="|";}{$1=$1; print "|"$0"|"}' <<<"$content" | pbcopy
	pbpaste
}
exit () {
	if [[ $SHLVL -eq 1 ]] && [[ $BASHPID == $$ ]]; then
		printf '%s\n' "Nice try!" >&2
	else
		command exit $1
	fi
}
decode_kubernetes_secret () {
	kubectl get secret "$@" -o json | jq '.data | map_values(@base64d)'
}
spongebobitize () {
    echo "$@" | awk '
{ 
  split($0, chars, "")
  for (i=1; i <= length($0); i++) {
    if (i%2==0) {
        printf("%s", tolower(chars[i]))
    } else {
        printf("%s", toupper(chars[i]))
    }
  }
}END{printf("\n")}'
}
cl_known_hosts () {
	local _line=$1
	if [[ -n "$_line" ]]; then
		sed -i.bak "${_line}d" /Users/jbutryn/.ssh/known_hosts
	fi
}
create_ps_record () {
	local _fqdn=$1
	local _ip=$2
	local _zone=${_fqdn#${_fqdn%.*.*.*}.}
	local _resource=${_fqdn//\./_}
	cat <<EOF
resource "ns1_record" "$_resource" {
  zone   = "$_zone"
  domain = "$_fqdn"
  type   = "A"
  ttl    = 300
  answers {
    answer = "$_ip"
  }
}
EOF
}
fix_docker () {
	docker kill $(docker ps -q)
	docker rm $(docker ps -a -q)
	docker rmi $(docker images -q)
	docker system prune
}
randpass () {
	local _length=$1
	LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c "${_length:-14}"; echo
}
print_csv () {
	local _n=$#
	for ((i=1;i<=_n;i++)); do
		if ((i==_n)); then
			printf '%s\n' "${!i}"
		else
			printf '%s,' "${!i}"
		fi
	done
}
black () {
	local _opts=(--line-length 120)
	if [[ $1 == diff ]]; then
		shift
		_opts+=(--diff --color)
	fi
	command black "${_opts[@]}" "$@" 
}
###########################
# Aliases
###########################
# enable color support of ls and also add handy aliases
if [[ -x /usr/bin/dircolors ]]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias r='fc -s'
alias cls='clear'
alias c='clear'
alias ll='ls -lahF'
alias l='ls -lahF'
alias xcode='open -a xcode'
alias text='open -a code'
alias pre='open -a Preview'
alias cd..='cd ..'
alias reload='source ~/.bash_profile'
alias merika='/Users/jbutryn/tools/personal/unit-conversion/merika'
alias innit='/Users/jbutryn/tools/personal/unit-conversion/innit'
alias hollowctl='/Users/jbutryn/tools/metal/hollowctl/hollowctl'
alias yum='brew'
alias rc='code ~/.bashrc'
alias profile='code ~/.bash_profile'
#alias ls='/usr/local/bin/gls --color'
alias ndate='node /Users/jbutryn/tools/personal/ndate/ndate.js'
alias gchoocher=/Users/jbutryn/tools/personal/gchoocher/bin/gchoocher
alias skookumq=/Users/jbutryn/tools/personal/skookumQ/bin/skookumq
alias git=mgit
alias tb='/Users/jbutryn/tools/metal/platops-toolbox/run.sh -m /Users/jbutryn -n host'
alias k=kubectl
alias debugpod='kubectl run -i --tty --rm debug --image=busybox --restart=Never -- /bin/bash'
alias kgetall='kubectl get $(kubectl api-resources --verbs=list -o name | paste -sd, -) --ignore-not-found --show-kind -o wide $NS'
alias ds="decode_kubernetes_secret"
alias metal='cd /Users/jbutryn/tools/metal'
alias cacherc='docker run -t cacherc cacherc'
alias mctl=/usr/local/bin/mctl
alias watch-css='sass --watch /Users/jbutryn/tools/metal/platops-web/platops-web/assets/main.scss:/Users/jbutryn/tools/metal/platops-web/platops-web/static/main.css'
alias mypython='. ~/mypython/bin/activate'
alias docker-dup='docker-compose down && docker-compose up -d'
alias docker-exec='docker-compose exec st2client bash'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi
###########################
# Miscellaneous
###########################
# make less more friendly for non-text input files, see lesspipe(1)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [[ -z "${debian_chroot:-}" ]] && [[ -r /etc/debian_chroot ]]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
###########################
# Prompt Config
###########################
my.prompt default
###########################
# Apps that mess with my
# path are annoying
###########################
PATH=/home/jesse/git/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH
