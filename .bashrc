#!/usr/bin/env bash
##############################################################################
# Sections:                                                                  #
#   01. General ................. General Bash behavior                      #
#   02. Aliases ................. Aliases                                    #
#   03. Functions ............... Helper functions                           #
#   04. Ruby .................... ruby installation                          #
##############################################################################

##############################################################################
# 01. General                                                                #
##############################################################################

WHITE='\[\e[1;37m\]'
#RED='\[\e[0;31m\]'
YELLOW='\[\e[1;33m\]'
BLUE='\[\e[0;36m\]'
PURPLE='\[\e[1;34m\]'
COLOR_RESET='\[\e[0m\]'
NODE='\[\e[1;32m'
#RUBY_VERSION='\[\e[1;31m\]'
#PYTHON='\[\e[1;32m\]'
#PYTHON='\[\e[1;36m\]'


function git_prompt() {
	# GIT PROMPT
	COLOR_GIT_CLEAN='\[\e[0;32m\]'
	COLOR_GIT_MODIFIED='\[\e[0;31m\]'
	COLOR_GIT_STAGED='\[\e[0;33m\]'


	if [ -e ".git" ]; then
		branch_name=$(git symbolic-ref -q HEAD)
		branch_name=${branch_name##refs/heads/}
		branch_name=${branch_name:-HEAD}

		echo -n "-["

		if [[ $(git status 2> /dev/null | tail -n1) = *"nothing to commit"* ]]; then
		echo -n "$COLOR_GIT_CLEAN$branch_name$COLOR_RESET"
		elif [[ $(git status 2> /dev/null | head -n5) = *"Changes to be committed"* ]]; then
		echo -n "$COLOR_GIT_STAGED$branch_name$COLOR_RESET"
		else
		echo -n "$COLOR_GIT_MODIFIED$branch_name*$COLOR_RESET"
		fi

		echo -n "$BLUE]$COLOR_RESET"
	fi
}

function node_version() {
	# Get the node version currently in use
	echo "$BLUE─[$COLOR_RESET$NODE⬢  - $(nvm version | cut -d'v' -f2-)$COLOR_RESET$BLUE]"
}

function prompt() {
	PS1="\n$BLUE┌─[$COLOR_RESET$YELLOW\u$COLOR_RESET$BLUE @ $COLOR_RESET$YELLOW\h$COLOR_RESET$BLUE]─[$COLOR_RESET$PURPLE\w$COLOR_RESET$BLUE]$(git_prompt)$(node_version)$COLOR_RESET\n$BLUE└─[$COLOR_RESET$WHITE\$$COLOR_RESET$BLUE]─› $COLOR_RESET"
}

PROMPT_COMMAND=prompt

export EDITOR="code -w"

##############################################################################
# 02. Aliases                                                                #
##############################################################################

# simple update alias
alias update='sudo apt update && sudo apt full-upgrade -y --allow-downgrades --fix-missing && sudo apt autoremove && snap refresh && flatpak update && npm-check -g -u'
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" \$HOME/.ssh/config | sed 's/Host //'"


##############################################################################
# 03. Functions                                                              #
##############################################################################

# Make a directory and move into it
mkcdir ()
{
	mkdir -p -- "$1" && cd -P -- "$1" || exit
}

# Kill a process that is holding the port number supplied
killport() {
	sudo fuser -k -TERM "$1"/tcp;
}

checkppas() {
	for f in /etc/apt/sources.list.d/*.list; do
		grep -Po "(?<=^deb\s).*?(?=#|$)" "$f" | while read -r ENTRY ; do

		# Sanitize entry line by removing stuff between square brackets
		ENTRY=$(echo "$ENTRY" | sed 's/\[.*\] //')

			HOST=$(cut -d/ -f3 <<< "$ENTRY")

			if [ "ppa.launchpad.net" = "$HOST" ]; then
			USER=$(cut -d/ -f4 <<< "$ENTRY")
			PPA=$(cut -d/ -f5 <<< "$ENTRY")
			packageCount=$(awk '$1=="Package:" {if (a[$2]++ == 0) {system("dpkg -l "$2)}}' /var/lib/apt/lists/*"$USER"*"$PPA"*Packages 2>/dev/null | awk '/^ii/' | wc -l)
			else
			USER=$(cut -d/ -f3 <<< "$ENTRY")
			PPA=$(cut -d/ -f4 <<< "$ENTRY")
			packageCount=$(awk '$1=="Package:" {if (a[$2]++ == 0) {system("dpkg -l "$2)}}' /var/lib/apt/lists/*"$USER"*Packages 2>/dev/null | awk '/^ii/' | wc -l)
			fi
			echo "$USER/$PPA    |    [$packageCount] package(s) installed"
			if [ "$packageCount" -eq 0 ] && [ "$1" == "--delete" ]; then
				sudo rm "$f" && echo "$f deleted"
			fi
			echo
		done
	done

}

##############################################################################
# 04. Ruby                                                                   #
##############################################################################

AUTCOMPLETE_LOCATION=~/.git-completion.bash
if [ -f $AUTCOMPLETE_LOCATION ]; then
	. "$AUTCOMPLETE_LOCATION"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
