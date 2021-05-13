require 'rubygems/version'

component 'puppet-runtime' do |pkg, settings, platform|
  pkg.url 'git://github.com/puppetlabs/puppet-runtime.git'
  pkg.ref settings[:version]

  # Ensure Vanagon does not try to use internal Puppet Inc. mirrors when
  # downloading sources.
  pkg.environment('VANAGON_USE_MIRRORS', 'n')
  # Pull in patch to work around `-e local` being ignored during build:
  #   https://tickets.puppetlabs.com/browse/VANAGON-163
  pkg.environment('VANAGON_LOCATION', 'https://github.com/puppetlabs/vanagon.git#00fe427')

  if Dir.exist?("resources/patches/puppet-runtime/#{platform.name}")
    patch_sets = Dir.entries("resources/patches/puppet-runtime/#{platform.name}").select {|e| e.match(/^\d+/)}.map {|p| Gem::Version.new(p) }
    patch_set = patch_sets.sort.reverse.find {|p| p <= settings[:version]}

    unless patch_set.nil?
      $stderr.puts("Applying patches for puppet-runtime/#{platform.name}/#{patch_set}")
      Dir.glob("resources/patches/puppet-runtime/#{platform.name}/#{patch_set}/*.patch").sort.each do |p|
        pkg.apply_patch p, fuzz: 2
      end
    end
  end

  # TODO: This only accounts for puppet-runtime components required to
  #       build puppet-agent 6.x. This logic will need to be extended
  #       to support 7.x.
  project_name = if Gem::Requirement.new('>= 202012140').satisfied_by?(settings[:version])
                   'agent-runtime-6.x'
                 else
                   'agent-runtime-master'
                 end

  pkg.configure do
    ['bundle config set path .bundle/lib',
     'bundle install']
  end

  pkg.build do
    ["bundle exec build #{project_name} #{platform.name} -e local"]
  end

  # This combines with projects/puppet-runtime.rb to copy the output/
  # directory from the nested Vanagon build to output/puppet-runtime
  #
  # components/puppet-agent.rb then copies this into its build tree to
  # create the following folder structure:
  #
  #   ├── puppet-agent/          <- puppet-agent package being built
  #   └── puppet-runtime/output/ <- Components required to build puppet-agent
  #
  # This facilitates development as puppet-agent and puppet-runtime can be
  # put in a directory by `git clone` and the relative path from the
  # puppet-agent project to compiled components created by puppet-runtime
  # is the same.
  pkg.install do
    ['mkdir -p /tmp/vanagon-puppet-runtime/puppet-runtime/',
     'cp -r output /tmp/vanagon-puppet-runtime/puppet-runtime/']
  end
end
