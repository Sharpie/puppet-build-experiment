component 'repo-definition' do |pkg, settings, platform|
  pkg.version '2019.12.25'

  if platform.is_deb?
    pkg.url "resources/repo/#{settings[:target_repo]}.list.txt"
    pkg.install_configfile "#{settings[:target_repo]}.list.txt", "/etc/apt/sources.list.d/#{settings[:target_repo]}.list"
    pkg.install do
      "sed -i 's|__CODENAME__|#{platform.codename}|g' /etc/apt/sources.list.d/#{settings[:target_repo]}.list"
    end
  else
    # RPM stuff.
  end
end
