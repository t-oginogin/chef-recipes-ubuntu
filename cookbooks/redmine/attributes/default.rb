default['redmine']['user'] = 'vagrant'
default['redmine']['packages'] = %w[imagemagick libmagick++-dev libmysqld-dev sysv-rc-conf]
default['redmine']['source_url'] = 'http://www.redmine.org/releases'
default['redmine']['source_dir'] = 'redmine-2.5.1'
default['redmine']['source_file'] = 'redmine-2.5.1.tar.gz'
default['redmine']['ruby_version'] = '2.0.0-p481'
default['redmine']['db_password'] = 'your_password'
default['redmine']['port'] = '3000'
