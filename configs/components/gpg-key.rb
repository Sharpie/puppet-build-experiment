component 'gpg-key' do |pkg, settings, platform|
  pkg.version '2019.12.25'

  if platform.is_deb?
    pkg.add_source 'resources/repo/sharpie-bintray.gpg'
    pkg.install_file 'sharpie-bintray.gpg', "/etc/apt/trusted.gpg.d/#{settings[:target_repo]}-keyring.gpg"
  else
    # RPM stuff.
  end
end
