#!/usr/bin/env bash

# Install apps distributed as .deb files on GitHub releases, which have no apt repo
# and so aren't updated by `apt full-upgrade`. Installed apps are updated if a newer
# release is available.
# Usage `scripts/install-github-deb.sh [--update]`
# `--update` only updates apps that are already installed, without installing missing ones.

GREEN='\e[32m'
NC='\e[0m'

# shellcheck source=scripts/latest-git-release.sh
source ~/dotfiles/scripts/latest-git-release.sh

# "package repo asset [ask]", where {version} in the asset is the release tag without a leading v,
# and `ask` prompts before installing the app (it's always updated once installed)
apps=(
	"rustdesk rustdesk/rustdesk rustdesk-{version}-x86_64.deb ask"
	"koodo-reader koodo-reader/koodo-reader Koodo-Reader-{version}-amd64.deb"
	"teams-for-linux IsmaelMartinez/teams-for-linux teams-for-linux_{version}_amd64.deb"
)

installed_version() {
	dpkg-query -W -f='${db:Status-Status} ${Version}' "$1" 2>/dev/null | sed -n 's/^installed //p'
}

# Usage `install_github_deb :package :repo :asset :current-version`
install_github_deb() {
	local package="$1" repo="$2" asset="$3" current="$4"
	local tag version dir

	tag="$(latest_git_release "$repo" 2>/dev/null)"
	if [ -z "$tag" ]; then
		echo "Failed to get the latest ${package} release"
		return 1
	fi
	version="${tag#v}"

	if [ "$current" = "$version" ]; then
		echo "${package} ${current} is up to date"
		return 0
	fi

	echo -e "\n${GREEN}Installing ${package} ${version}${current:+ (from ${current})}...${NC}"
	dir="$(mktemp -d)"
	wget -q "https://github.com/${repo}/releases/download/${tag}/${asset//\{version\}/$version}" -O "${dir}/${package}.deb" &&
		sudo apt -qq install -y "${dir}/${package}.deb" || {
		echo "Failed to download or install ${package}"
		rm -rf "$dir"
		return 1
	}
	rm -rf "$dir"
}

update_only=false
[ "${1:-}" = "--update" ] && update_only=true

status=0
for app in "${apps[@]}"; do
	read -r package repo asset ask <<<"$app"
	current="$(installed_version "$package")"
	if [ -z "$current" ]; then
		$update_only && continue
		if [ "$ask" = "ask" ]; then
			echo
			read -p "Do you want to install ${package} (y/n)? " -n 1 -r
			echo
			[[ $REPLY =~ ^[Yy]$ ]] || continue
		fi
	fi
	install_github_deb "$package" "$repo" "$asset" "$current" || status=1
done
exit "$status"
