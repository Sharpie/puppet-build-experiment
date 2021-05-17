require 'rubygems/version'

component 'puppet-agent' do |pkg, settings, platform|
  pkg.url 'git://github.com/puppetlabs/puppet-agent.git'
  pkg.ref settings[:version]

  pkg.add_source(File.expand_path('output/puppet-runtime'))

  # Ensure Vanagon does not try to use internal Puppet Inc. mirrors when
  # downloading sources.
  pkg.environment('VANAGON_USE_MIRRORS', 'n')

  unless Gem::Requirement.net('>= 6.21.0').satisfied_by?(settings[:version])
    # Pull in patch to work around `-e local` being ignored during build:
    #   https://tickets.puppetlabs.com/browse/VANAGON-163
    pkg.environment('VANAGON_LOCATION', 'https://github.com/puppetlabs/vanagon.git#00fe427')
  end

  if Dir.exist?("resources/patches/puppet-agent/#{platform.name}")
    patch_sets = Dir.entries("resources/patches/puppet-agent/#{platform.name}").select {|e| e.match(/^\d+/)}.map {|p| Gem::Version.new(p) }
    patch_set = patch_sets.sort.reverse.find {|p| p <= settings[:version]}

    unless patch_set.nil?
      $stderr.puts("Applying patches for puppet-agent/#{platform.name}/#{patch_set}")
      Dir.glob("resources/patches/puppet-agent/#{platform.name}/#{patch_set}/*.patch").sort.each do |p|
        pkg.apply_patch p, fuzz: 2
      end
    end
  end

  pkg.configure do
    ['bundle config set path .bundle/lib',
     'bundle install',
     %(sed -Eie "s|http[^\\"]+|file://$(realpath puppet-runtime/output)|" configs/components/puppet-runtime.json)]
  end

  pkg.build do
    ["bundle exec build puppet-agent #{platform.name} -e local"]
  end

  pkg.install do
    ['mkdir -p /tmp/vanagon-puppet-agent/',
     'cp -r output/* /tmp/vanagon-puppet-agent/']
  end
end
