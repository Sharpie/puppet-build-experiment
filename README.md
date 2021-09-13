# Puppet Build Experiment

A 1000% expermental set of tools for building `puppet-agent`. Anything related
to or produced by this repo may change or be deleted at any moment.

The code in this version of the repository cross-compiles the `puppet-agent`
package for Raspbian using a Debian 10 x86_64 container running the official
Debian `crossbuild-essential-armhf` tools. This approach provides decent
build speed while also running in an x86_64 environment, which is the
easiest to find in 2021. A dis-advantage is that the Debian cross build tools
target the ARMv7 architecture and newer. The Raspberry Pi 0 and 1 use a ARMv6
CPU which means that the `puppet-agent` binaries will fail to run on those
platforms with an "illegal instruction" error.


## Usage

To use the automation in this repo, you will need the following dependencies:

  - Docker
  - Ruby 2.4 or newer, with the `bundler` gem installed
  - If building on Linux, `qemu-user-static` to provide support for running
    cross-compiled ARM binaries via `binfmt_misc`.
  - The `jq` tool is optional, but can be helpful for manipulating JSON.

You will also need at least 4 GB of RAM or swap available to avoid oomkills
during C++ compilation.

Once the above dependencies are installed, clone the project and use Bundler to
install the items listed in the `Gemfile`:

```
bundle install --path=.bundle/lib
```

The `puppet-agent` packages provided by this repo are built using the
[Vanagon][vanagon] `build` command. This command **must** be executed
from the top directory of the repository in order for relative paths
to resolve properly.

The builds are designed to run inside a Docker container that provides
a cross-compilation environment. This container is configured using
environment variables:

  - `VANAGON_DOCKER_IMAGE`: Docker image to use in the build. The container
    must run a SSH daemon that listens to port 22 as Vanagon uses SSH to execute
    commands and Rsync-over-SSH to transfer files.
  - `VANAGON_DOCKER_RUN_ARGS`: Arguments to pass to `docker run` when launching
    the image. Usually file systems that must be mounted for SystemD to start.
  - `VANAGON_SSH_PORT`: The ssh port that Docker should expose.
  - `VANAGON_SSH_KEY`: The ssh key that Vanagon should use.

[vanagon]: https://github.com/puppetlabs/vanagon

### Example

The following example builds `puppet-agent` 6.21.1 for Debian 10 ARM using
a Docker container provided by [sharpie/puppet-dev-images][dev-images]:

```bash
curl -O https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant
chmod 0600 vagrant

export VANAGON_SSH_KEY="${PWD}/vagrant"
export VANAGON_SSH_PORT=4222

export VANAGON_DOCKER_IMAGE='ghcr.io/sharpie/debian-10-amd64:latest'
docker pull "${VANAGON_DOCKER_IMAGE}"
export VANAGON_DOCKER_RUN_ARGS=$(docker inspect "${VANAGON_DOCKER_IMAGE}" --format '{{ index .Config.Labels "docker-run-args" }}')

agent_version=6.21.1
runtime_version=$(curl -sSL "https://raw.githubusercontent.com/puppetlabs/puppet-agent/${agent_version}/configs/components/puppet-runtime.json"|jq --raw-output '.version')

VANAGON_BUILD_VERSION=$runtime_version bundle exec build puppet-runtime debian-10-armhf -e docker
VANAGON_BUILD_VERSION=$agent_version bundle exec build puppet-agent debian-10-armhf -e docker
```

The [build_puppet-agent_debian-10-armhf.yaml][build-debian10] action demonstrates
applying the above example to an Ubuntu 20.04 VM.

[build-debian10]: .github/workflows/build_puppet-agent_debian-10-armhf.yaml

[dev-images]: https://github.com/sharpie/puppet-dev-images
