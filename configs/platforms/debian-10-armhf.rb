platform "debian-10-armhf" do |plat|
  plat.servicedir "/lib/systemd/system"
  plat.defaultdir "/etc/default"
  plat.servicetype "systemd"
  plat.codename "buster"
  plat.platform_triple "arm-linux-gnueabihf"
  plat.cross_compiled "true"

  plat.install_build_dependencies_with "DEBIAN_FRONTEND=noninteractive; apt-get install -qy --no-install-recommends "
  plat.provision_with "dpkg --add-architecture #{plat.get_architecture}"

  packages = [
    'build-essential',
    'git',
    'ruby',
    'ruby-bundler',
    'rsync'
  ]
  plat.provision_with "export DEBIAN_FRONTEND=noninteractive; apt-get update -qq; apt-get install -qy --no-install-recommends #{packages.join(' ')}"


  plat.vmpooler_template "debian-10-x86_64"

  plat.docker_image ENV['VANAGON_DOCKER_IMAGE']
  plat.docker_run_args ENV['VANAGON_DOCKER_RUN_ARGS'].split(' ')
  plat.ssh_port ENV['VANAGON_SSH_PORT']
end
