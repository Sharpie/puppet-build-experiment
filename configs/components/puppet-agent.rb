require 'rubygems/version'

component 'puppet-agent' do |pkg, settings, platform|
  pkg.url 'git://github.com/puppetlabs/puppet-agent.git'
  pkg.ref settings[:version]

  pkg.add_source(File.expand_path('output/puppet-runtime'))

  # Update the Vanagon version to ensure the newest features added for
  # community builds are present.
  # NOTE: If Vanagon hits 1.0, this may no longer work.
  pkg.environment('VANAGON_LOCATION', "https://github.com/puppetlabs/vanagon.git##{VANAGON_VERSION}")
  # Ensure Vanagon does not try to use internal Puppet Inc. mirrors when
  # downloading sources.
  pkg.environment('VANAGON_USE_MIRRORS', 'n')
  pkg.environment('PUPPET_RUNTIME_LOCATION', '../puppet-runtime/output')

  if Dir.exist?("resources/patches/puppet-agent/#{platform.name}")
    patch_sets = Dir.entries("resources/patches/puppet-agent/#{platform.name}").select {|e| e.match(/^\d+/)}.map {|p| Gem::Version.new(p) }
    patch_set = patch_sets.sort.reverse.find {|p| p <= settings[:version]}

    unless patch_set.nil?
      $stderr.puts("Applying patches for puppet-agent/#{platform.name}/#{patch_set}")
      Dir.glob("resources/patches/puppet-agent/#{platform.name}/#{patch_set}/*.patch").each do |p|
        pkg.apply_patch p
      end
    end
  end

  pkg.configure do
    ['bundle install --path=.bundle/lib']
  end

  pkg.build do
    ["bundle exec build puppet-agent #{platform.name} -e local"]
  end

  pkg.install do
    ['mkdir -p /tmp/vanagon-puppet-agent/',
     'cp -r output/* /tmp/vanagon-puppet-agent/']
  end
end
