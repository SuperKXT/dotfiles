#!/usr/bin/env bash

# Install mise, which manages Node and the global CLIs listed in
# dot/.config/mise/config.toml, then install every tool in that config.

GREEN='\e[32m'
NC='\e[0m'

mise_bin="$HOME/.local/bin/mise"

if [ ! -x "$mise_bin" ]; then
	echo -e "\n${GREEN}Installing mise...${NC}"
	curl -fsSL https://mise.run | sh || {
		echo "Failed to install mise"
		exit 1
	}
fi

# Link the global config now, since the rest of the dotfiles are linked at the end of the install
mkdir -p ~/.config/mise
ln -sf ~/dotfiles/dot/.config/mise/config.toml ~/.config/mise/config.toml

# Shims put mise's tools on PATH for programs that never run .bashrc (editors, launchers, systemd)
if ! grep -qF 'mise/shims' ~/.profile 2>/dev/null; then
	# shellcheck disable=SC2016
	printf '\n# mise shims, for programs that do not run .bashrc\nexport PATH="$HOME/.local/share/mise/shims:$PATH"\n' >>~/.profile
fi

echo -e "\n${GREEN}Setting Up mise Tools...${NC}"
"$mise_bin" install
