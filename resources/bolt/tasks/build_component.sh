#!/bin/bash

set -e

declare PT_agent_version
declare PT_project_version
declare PT_component

export VANAGON_USE_MIRRORS=n
export VANAGON_DOCKER_IMAGE=ghcr.io/sharpie/raspbian-10-armhf

if [[ ! -e puppet-build-experiment ]]; then
  git clone --depth=1 https://github.com/Sharpie/puppet-build-experiment

  pushd puppet-build-experiment

  if [[ -n "${PT_project_version}" ]]; then
    git fetch origin "${PT_project_version}"
    git checkout "${PT_project_version}"
  fi

  bundle config set path .bundle/lib
  bundle install

  popd
fi

pushd puppet-build-experiment

case "${PT_component}" in
  runtime)
    runtime_version=$(./scripts/component-version.sh puppet-agent "{$PT_agent_version}" puppet-runtime)

    env VANAGON_BUILD_VERSION="${runtime_version}" bundle exec build puppet-runtime debian-10-armhf -e docker
    ;;
  agent)
    env VANAGON_BUILD_VERSION="${PT_agent_version}" bundle exec build puppet-agent debian-10-armhf -e docker
    ;;
esac
