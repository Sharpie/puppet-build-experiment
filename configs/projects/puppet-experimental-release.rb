project 'puppet-experimental-release' do |proj|
  proj.description 'Release package for https://bintray.com/sharpie/puppet-experimental-* repositories'
  proj.release '1'
  proj.license 'ASL 2.0'
  proj.version '1.0.0'
  proj.vendor 'Charlie Sharpsteen <source@sharpsteen.net>'

  proj.homepage 'https://github.com/Sharpie/puppet-build-experiment/'
  proj.target_repo 'puppet-experimental'
  proj.noarch

  proj.setting(:target_repo, 'puppet-experimental')

  # Set up a conflict with the official Puppet repos.
  proj.conflicts 'puppet-release'
  proj.conflicts 'puppet5-release'
  proj.conflicts 'puppet6-release'

  # Replace https://bintray.com/sharpie/puppet-raspbian-spike
  proj.replaces 'puppet-raspbian-spike-release'

  proj.component 'gpg-key'
  proj.component 'repo-definition'
end
