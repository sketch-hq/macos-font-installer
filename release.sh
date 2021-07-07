#!/usr/bin/env bash

set -eu -o pipefail

# Constants
GITHUB_ORG=sketch-hq
GITHUB_REPO=macos-font-installer

# Derive the release version from the tag (stripping the v prefix)
TAG=${1}
VERSION=$(echo ${TAG} | sed 's/v//g')

# Generate the release changelog based on the commit log
SHA1=$(git rev-parse HEAD)
DIFF=$(git tag --sort=-creatordate | grep -A 1 ${TAG} | sed '1!G;h;$!d' | xargs echo -n | sed 's/ /.../g')
CHANGELOG=$(git log --pretty='format:- %h: %s' ${DIFF})

ghr -u ${GITHUB_ORG} -r ${GITHUB_REPO} \
-n "Version ${VERSION}" \
-b "${CHANGELOG}" \
-c ${SHA1} ${TAG} ./bin/macos-font-installer
