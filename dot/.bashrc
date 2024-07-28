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

# some more ls aliases
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ls='ls --color=auto'
alias ssh-hosts="grep -P \"^Host ([^*]+)$\" \$HOME/.ssh/config | sed 's/Host //'"
alias git-open="gh repo view --web"
alias apti="apt list --installed | grep"
alias pn='pnpm'
alias pnx='pnpm dlx'
alias open='xdg-open'
alias cat='batcat --paging=never'

##############################################################################
# 03. Functions                                                              #
##############################################################################

# update the environment
# TODO fix vscode and azuredatastudio not updating automatically
update() {
	sudo apt update &&
		sudo apt full-upgrade -y --allow-downgrades --fix-missing &&
		sudo apt autoremove
	~/dotfiles/scripts/install-nvm.sh
	nvm-update lts/*
	nvm use lts/*
	corepack prepare yarn@stable --activate
	corepack prepare pnpm@latest --activate
	npm-check -gu
	nvm-update node
	nvm use node
	corepack prepare yarn@stable --activate
	corepack prepare pnpm@latest --activate
	npm-check -gu
	nvm use default
	curl --progress-bar https://gist.githubusercontent.com/SanderTheDragon/1331397932abaa1d6fbbf63baed5f043/raw/postman-deb.sh | sh
	deno upgrade
}

# Make a directory and move into it
mkcd() {
	mkdir -p -- "$1" && cd -P -- "$1" || return
}

# Kill a process that is holding the port number supplied
killport() {
	sudo kill -9 "$(sudo fuser -n tcp "$1" 2>/dev/null)"
}

# Find wordle solution words
wordle() {
	cd ~/repos/playground/ && pn wordle "$@" && cd - >/dev/null || return
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

# udpate nvm version
nvm-update() {
	echo
	echo "Updating Node Version $1"
	echo
	local current
	local remote
	current="$(nvm version "$1")"
	if [ "$current" = "N/A" ]; then
		echo "Version $1 Not Found!"
		versions="$(nvm ls --no-alias --no-colors | xargs)"
		versions=${versions//->/}
		versions=${versions// v/v}
		versions=${versions//\*/}
		# ! Don't fix this [shellcheck] warning!
		versions=($versions)
		PS3="Select A Version To Use As $1: "
		select current in "${versions[@]}"; do
			if [ -n "$current" ]; then
				break
			fi
		done
		echo
	fi

	remote="$(nvm version-remote "$1")"
	if [ "$remote" = "N/A" ]; then
		echo "Version $1 Not Found On Remote"
	elif [ "$current" = "$remote" ]; then
		echo "Version $1 Is Up To Date"
	else
		echo "Updating $1 From $current To $remote"
		nvm install "$1" --latest-npm --reinstall-packages-from="$current"
		nvm use "$current"
		npm ls -gp --depth=0 | awk -F/ '/node_modules/ && !/\/npm$/ {print $NF}' | xargs npm -g rm
		nvm use "$1"
		nvm uninstall "$current"
	fi
}

##############################################################################
# 04. Setup Environments                                                     #
##############################################################################

dir="$HOME/.config/bash-completion/completions"
if [[ -d "$dir" && -r "$dir" && -x "$dir" ]]; then
	for file in "$dir"/*; do
		# shellcheck source=/dev/null
		[[ -f "$file" && -r "$file" ]] && source "$file"
	done
fi

if [ -f "$HOME"/.bash.profile ]; then
	# shellcheck source=/dev/null
	source "$HOME"/.bash.profile
fi

eval "$(direnv hook bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

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

###-begin-pm2-completion-###
### credits to npm for the completion file model
#
# Installation: pm2 completion >> ~/.bashrc  (or ~/.zshrc)
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
	_pm2_completion() {
		local si="$IFS"
		IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
			COMP_LINE="$COMP_LINE" \
			COMP_POINT="$COMP_POINT" \
			pm2 completion -- "${COMP_WORDS[@]}" \
			2>/dev/null)) || return $?
		IFS="$si"
	}
	complete -o default -F _pm2_completion pm2
elif type compctl &>/dev/null; then
	_pm2_completion() {
		local cword line point words si
		read -Ac words
		read -cn cword
		let cword-=1
		read -l line
		read -ln point
		si="$IFS"
		IFS=$'\n' reply=($(COMP_CWORD="$cword" \
			COMP_LINE="$line" \
			COMP_POINT="$point" \
			pm2 completion -- "${words[@]}" \
			2>/dev/null)) || return $?
		IFS="$si"
	}
	compctl -K _pm2_completion + -f + pm2
fi
###-end-pm2-completion-###

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
	_npm_completion() {
		local words cword
		if type _get_comp_words_by_ref &>/dev/null; then
			_get_comp_words_by_ref -n = -n @ -n : -w words -i cword
		else
			cword="$COMP_CWORD"
			words=("${COMP_WORDS[@]}")
		fi

		local si="$IFS"
		if ! IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
			COMP_LINE="$COMP_LINE" \
			COMP_POINT="$COMP_POINT" \
			npm completion -- "${words[@]}" \
			2>/dev/null)); then
			local ret=$?
			IFS="$si"
			return $ret
		fi
		IFS="$si"
		if type __ltrim_colon_completions &>/dev/null; then
			__ltrim_colon_completions "${words[cword]}"
		fi
	}
	complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
	_npm_completion() {
		local si=$IFS
		compadd -- $(COMP_CWORD=$((CURRENT - 1)) \
			COMP_LINE=$BUFFER \
			COMP_POINT=0 \
			npm completion -- "${words[@]}" \
			2>/dev/null)
		IFS=$si
	}
	compdef _npm_completion npm
elif type compctl &>/dev/null; then
	_npm_completion() {
		local cword line point words si
		read -Ac words
		read -cn cword
		let cword-=1
		read -l line
		read -ln point
		si="$IFS"
		if ! IFS=$'\n' reply=($(COMP_CWORD="$cword" \
			COMP_LINE="$line" \
			COMP_POINT="$point" \
			npm completion -- "${words[@]}" \
			2>/dev/null)); then

			local ret=$?
			IFS="$si"
			return $ret
		fi
		IFS="$si"
	}
	compctl -K _npm_completion npm
fi
###-end-npm-completion-###

# pnpm tabtab source for packages
# uninstall by removing these lines
[ -f ~/.config/tabtab/bash/__tabtab.bash ] && . ~/.config/tabtab/bash/__tabtab.bash || true

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.1.8937393
