#!/usr/bin/env bash

GREEN='\e[32m'
NC='\e[0m'

# Install Docker & Docker-Compose
if ! command -v docker &>/dev/null; then
	echo -e "\n${GREEN}Installing Docker...${NC}"
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt -qq remove $pkg; done
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker "$USER"
	newgrp docker
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
	rm ./get-docker.sh
	docker volume create portainer_data
	docker run -d -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
fi
