#!/usr/bin/env bash
##############################################################################
# Sections:                                                                  #
#   01. General ............................. General Bash behavior          #
#   02. Aliases ............................. Aliases                        #
#   03. Functions ........................... Helper functions               #
#   04. Setup Environments .................. node, mise and bash setup      #
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
update() {
	sudo apt update &&
		sudo apt full-upgrade -y --allow-downgrades --fix-missing &&
		sudo apt autoremove
	flatpak update -y
	flatpak uninstall --unused -y
	if command -v rclone &>/dev/null; then
		sudo rclone selfupdate --package deb
		systemctl --user try-restart rclone-gdrive
	fi
	[ -x "$HOME/.local/bin/bw" ] && ~/dotfiles/scripts/install-bitwarden.sh --update-cli
	~/dotfiles/scripts/install-github-deb.sh --update
	command -v turso &>/dev/null && turso update
	command -v gh &>/dev/null && gh extension upgrade --all
	~/dotfiles/scripts/install-watchman.sh --update
	~/dotfiles/scripts/install-portainer.sh --update
	~/dotfiles/scripts/install-fonts.sh --update
	~/dotfiles/scripts/install-tela-icons.sh --update
	~/dotfiles/scripts/install-android-sdk.sh --update
	mise self-update -y
	mise upgrade
}

# Make a directory and move into it
mkcd() {
	mkdir -p -- "$1" && cd -P -- "$1" || return
}

# Kill a process that is holding the port number supplied
killport() {
	lsof -ti:"$1" | xargs -r kill
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

# Connect to a named alias via RustDesk
rdp() {
    local name="$1"
    local peer_dir="$HOME/.config/rustdesk/peers"
    local peer_file peer_id

    peer_file=$(grep -rl "alias = '$name'" "$peer_dir" 2>/dev/null | head -1)
    if [[ -z "$peer_file" ]]; then
        echo "No peer found with alias: $name"
        return 1
    fi

    peer_id=$(basename "$peer_file" .toml)
    rustdesk --connect "$peer_id" >/dev/null 2>&1 & disown
}

_rdp_complete() {
    local peer_dir="$HOME/.config/rustdesk/peers"
    local aliases

    aliases=$(grep -rh "alias = " "$peer_dir" 2>/dev/null \
        | sed "s/alias = '//;s/'//")

    COMPREPLY=($(compgen -W "$aliases" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _rdp_complete rdp

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

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/25.1.8937393

# Turso
export PATH="$PATH:/home/superkxt/.turso"
export PATH="$HOME/.local/bin:$PATH"

# Puts Node and the other mise tools on PATH, switching versions per project
eval "$(mise activate bash)"
