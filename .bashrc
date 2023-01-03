#!/usr/bin/env bash
##############################################################################
# Sections:                                                                  #
#   01. General ............................. General Bash behavior          #
#   02. Aliases ............................. Aliases                        #
#   03. Functions ........................... Helper functions               #
#   04. Setup Environments .................. node, nvm and bash setup       #
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

		if [[ $(git status 2>/dev/null | tail -n1) = *"nothing to commit"* ]]; then
			echo -n "$COLOR_GIT_CLEAN$branch_name$COLOR_RESET"
		elif [[ $(git status 2>/dev/null | head -n5) = *"Changes to be committed"* ]]; then
			echo -n "$COLOR_GIT_STAGED$branch_name$COLOR_RESET"
		else
			echo -n "$COLOR_GIT_MODIFIED$branch_name*$COLOR_RESET"
		fi

		echo -n "$BLUE]$COLOR_RESET"
	fi
}

function node_version() {
	# Get the node version currently in use
	echo "$BLUE─[$COLOR_RESET$NODE⬢  - $(node -v | cut -d'v' -f2-)$COLOR_RESET$BLUE]"
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
alias setup-postman='curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh'
alias pn-update='corepack prepare pnpm@latest --activate'
alias update='sudo apt update && sudo apt full-upgrade -y --allow-downgrades --fix-missing && sudo apt autoremove && snap refresh && flatpak update && nvm use lts/* && npm-check -gu && pn-update  && nvm use node && npm-check -gu && pn-update && nvm use default && curl https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh'
# some more ls aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" \$HOME/.ssh/config | sed 's/Host //'"
alias git-open="gh repo view --web"
alias apti="apt list --installed | grep"
alias pn='pnpm'
alias open='xdg-open'
alias proton='protonvpn-cli'
alias cat='batcat --paging=never'

##############################################################################
# 03. Functions                                                              #
##############################################################################

# Make a directory and move into it
mkcdir() {
	mkdir -p -- "$1" && cd -P -- "$1" || return
}

# Kill a process that is holding the port number supplied
killport() {
	sudo kill -9 "$(sudo fuser -n tcp "$1" 2>/dev/null)"
}

# Find wordle solution words
wordle() {
	cd ~/repos/personal/playground/ && pn wordle "$@" && cd - >/dev/null || return
}

# recursively rename the given path and all its contents to kebab case
kebab-rename() {
	cd ~/repos/personal/playground/ && pn kebab-rename "$@" && cd - >/dev/null || return
}

# Get all local ips
local-ip() {
	ifconfig | grep "inet" | grep -Fv 127.0.0.1 | awk '{print $2}'
}

# Get public ip
public-ip() {
	curl ipinfo.io/ip
}

# alias for git log --oneline -n $1
gimme() {
	git log --oneline -n "$1"
}

#udpate nvm version
nvm-update() {
	nvm install "$1" --latest-npm --reinstall-packages-from="$2"
	nvm uninstall "$2"
	nvm use default
}

##############################################################################
# 04. Setup Environments                                                     #
##############################################################################

if [ -f ~/.git-completion.bash ]; then
	. ~/.git-completion.bash
fi

if [ -f ~/.ssh-completion.bash ]; then
	. ~/.ssh-completion.bash
fi

if [ -f ~/.bash.profile ]; then
	. ~/.bash.profile
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

cdnvm() {
	command cd "$@" || return
	nvm_path=$(nvm_find_up .nvmrc | tr -d '\n')

	# If there are no .nvmrc file, use the default nvm version
	if [[ ! $nvm_path = *[^[:space:]]* ]]; then

		declare default_version
		default_version=$(nvm version default)

		# If there is no default version, set it to `node`
		# This will use the latest version on your machine
		if [[ $default_version == "N/A" ]]; then
			nvm alias default node
			default_version=$(nvm version default)
		fi

		# If the current version is not the default version, set it to use the default version
		if [[ $(nvm current) != "$default_version" ]]; then
			nvm use default
		fi

	elif [[ -s $nvm_path/.nvmrc && -r $nvm_path/.nvmrc ]]; then
		declare nvm_version
		nvm_version=$(<"$nvm_path"/.nvmrc)

		declare locally_resolved_nvm_version
		# `nvm ls` will check all locally-available versions
		# If there are multiple matching versions, take the latest one
		# Remove the `->` and `*` characters and spaces
		# `locally_resolved_nvm_version` will be `N/A` if no local versions are found
		locally_resolved_nvm_version=$(nvm ls --no-colors "$nvm_version" | tail -1 | tr -d '\->*' | tr -d '[:space:]')

		# If it is not already installed, install it
		# `nvm install` will implicitly use the newly-installed version
		if [[ "$locally_resolved_nvm_version" == "N/A" ]]; then
			nvm install "$nvm_version"
		elif [[ $(nvm current) != "$locally_resolved_nvm_version" ]]; then
			nvm use "$nvm_version"
		fi
	fi
}
alias cd='cdnvm'
cd "$PWD" || return
