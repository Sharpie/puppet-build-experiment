require 'rubygems/version'

project 'puppet-runtime' do |proj|
  platform = proj.get_platform
  proj.version ENV['VANAGON_BUILD_VERSION']

  proj.setting :version, Gem::Version.new(ENV['VANAGON_BUILD_VERSION'])
  proj.generate_packages false
  proj.no_packaging true

  proj.component 'puppet-runtime'
  proj.fetch_artifact('/tmp/vanagon-puppet-runtime/puppet-runtime')
end
