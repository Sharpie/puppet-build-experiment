test_name "Install Puppet Agent Packages" do
  agents.each do |agent|
    local = ENV['TEST_PUPPET_PACKAGE']
    remote = File.join('/root', File.basename(local))

    scp_to(agent, local, remote)
    agent.execute('apt update')
    agent.execute("env DEBIAN_FRONTEND=noninteractive apt install -y '#{remote}'")
    agent[:version] = ENV['SHA']

    agent.execute('mkdir -p /opt/puppetlabs/puppet/etc')
    # Generating gem documentation takes sooooooooo looong when
    # running under emulation. Seriously. Like 20 minutes.
    agent.execute('printf "gem: --no-document" > /opt/puppetlabs/puppet/etc/gemrc')
    configure_type_defaults_on([agent])
  end

  # make sure install is sane, beaker has already added puppet and ruby
  # to PATH in ~/.ssh/environment
  agents.each do |agent|
    on agent, puppet('--version')
    ruby = ruby_command(agent)
    on agent, "#{ruby} --version"
  end
end
