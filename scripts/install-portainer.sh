#!/usr/bin/env bash

# Run Portainer in Docker, or recreate its container if a newer image is available.
# Usage `scripts/install-portainer.sh [--update]`
# `--update` only updates Portainer if its container already exists.

GREEN='\e[32m'
NC='\e[0m'

image="portainer/portainer-ce:latest"

command -v docker &>/dev/null || exit 0

run_portainer() {
	docker volume create portainer_data >/dev/null
	docker run -d -p 9000:9000 --name portainer --restart=always \
		-v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data "$image"
}

if ! docker container inspect portainer &>/dev/null; then
	[ "${1:-}" = "--update" ] && exit 0
	echo -e "\n${GREEN}Installing Portainer...${NC}"
	run_portainer
	exit
fi

docker pull -q "$image" >/dev/null || {
	echo "Failed to pull the Portainer image"
	exit 1
}
if [ "$(docker container inspect -f '{{.Image}}' portainer)" = "$(docker image inspect -f '{{.Id}}' "$image")" ]; then
	echo "Portainer is up to date"
	exit 0
fi

# The data lives in the portainer_data volume, so the container can be replaced
echo -e "\n${GREEN}Updating Portainer...${NC}"
docker rm -f portainer >/dev/null && run_portainer
