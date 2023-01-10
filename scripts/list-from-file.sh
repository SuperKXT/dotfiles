#!/usr/bin/env bash

list_from_file() {
	local packages=''
	while IFS= read -r line; do
		packages+=" $line"
	done <"$1"
	echo "$packages"
}
