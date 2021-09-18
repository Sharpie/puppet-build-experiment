#!/bin/bash

# Provision a Debian node to build Raspbian packages
#
# This class sets up a Debian node with the components required
# to build Raspbian packages inside of docker containers.
#
# This configuration assumes an ARM 64 operating system and
# configures it to run ARM 32 containers. Normally, this isn't
# required to run a 32-bit userland on top of a 64-bit host.
# However the build tools need to _believe_ they are running
# on a 32-bit host in order to make the right decisions.
#
# @see https://thegeeklab.de/posts/run-arm32-docker-daemon-on-arm64-servers/

set -e

export DEBIAN_FRONTEND=noninteractive

apt update
apt install -y build-essential ca-certificates curl git gpg jq ruby-bundler ruby-dev tmux vim

mkdir -p /etc/systemd/system/docker.service.d
cat <<'EOF' >/etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/setarch linux32 -B /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
EOF

mkdir -p /etc/systemd/system/containerd.service.d
cat <<'EOF' >/etc/systemd/system/containerd.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/setarch linux32 -B /usr/bin/containerd
EOF

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

cat <<'EOF' >/etc/apt/sources.list.d/docker.list
deb [arch=armhf] https://download.docker.com/linux/debian buster stable
EOF

dpkg --add-architecture armhf
apt update

apt install -y docker-ce:armhf

usermod -aG docker admin
