source 'https://rubygems.org'

# Mostly copied from the dependencies of:
#   https://rubygems.org/gems/puppet-module-posix-dev-r2.5
gem 'puppet_litmus', '>= 0.13.1', '< 1.0.0'
gem 'puppetlabs_spec_helper', '>= 2.9.0', '< 3.0.0'
gem 'rake', '~> 12.3'
gem 'serverspec', '~> 2.41'

gem 'vanagon', git: 'https://github.com/Sharpie/vanagon',
               ref: 'f3e0c88'

eval_gemfile "#{__FILE__}.local" if File.exists? "#{__FILE__}.local"
