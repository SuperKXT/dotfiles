#!/usr/bin/env bash

# Usage `github_api "repos/:user/:repo/releases"`
# Uses the authenticated gh CLI when possible, since unauthenticated requests are limited to 60 an hour
github_api() {
	if command -v gh &>/dev/null && gh auth status &>/dev/null; then
		gh api "$1"
	else
		curl -fsSL "https://api.github.com/$1"
	fi
}

# Usage `latest_git_release ":user/:repo"`
latest_git_release() {
	github_api "repos/$1/releases/latest" | jq -r '.tag_name // empty'
}
