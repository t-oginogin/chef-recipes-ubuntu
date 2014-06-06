#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

redmine_user = node['redmine']['user']
source_url = node['redmine']['source_url']
source_dir = node['redmine']['source_dir']
source_file = node['redmine']['source_file']
ruby_version = node['redmine']['ruby_version']
db_password = node['redmine']['db_password']
port = node['redmine']['port']

remote_file "/home/#{redmine_user}/#{source_file}" do
  not_if "test -e #{source_file}"
  source "#{source_url}/#{source_file}"
end

bash 'deploy redmine' do
  code <<-EOL
    not_if "test -e /var/www/#{source_dir}"
    sudo mkdir /var/www/
    mv /home/#{redmine_user}/#{source_file} /var/www/
    cd /var/www/
    tar xvzf #{source_file}
  EOL
end

bash 'set ruby 2.0.0' do
  user "#{redmine_user}"
  code <<-EOL
    cd /var/www/#{source_dir}
    source ~/.bash_profile
    if ! rbenv version | grep #{ruby_version}; then
      rbenv install #{ruby_version}
      rbenv local #{ruby_version}
      rbenv rehash
    fi
  EOL
end

node['redmine']['packages'].each do |package|
  package "#{package}" do
    action :install
  end
end

template "/var/www/#{source_dir}/config/database.yml" do
  user "#{redmine_user}"
  source 'database.yml.erb'
  
  variables ({
    :db_password => "#{db_password}"
  })
end

bash 'install gems' do
  user "#{redmine_user}"
  code <<-EOL
    cd /var/www/#{source_dir}
    source ~/.bash_profile
    rbenv local 2.0.0-p481
    rbenv rehash
    gem install bundler
    gem install mysql2
    bundle install --without development test
    rbenv rehash
  EOL
end

bash 'initialize db for application' do
  not_if "mysql -u root -p#{db_password} -e 'show databases' | grep 'redmine'"

  code <<-EOL
    mysql -u root -p#{db_password} -e "create database redmine character set utf8;"
    mysql -u root -p#{db_password} -e "create database redmine_development character set utf8;"
    mysql -u root -p#{db_password} -e "create database redmine_test character set utf8;"
    mysql -u root -p#{db_password} -e "grant all privileges on redmine.* to 'root'@'localhost' identified by '#{db_password}';"
  EOL
end

bash 'prepare startup' do
  user "#{redmine_user}"
  code <<-EOL
    cd /var/www/#{source_dir}
    source ~/.bash_profile
    bundle exec rake generate_secret_token
    bundle exec rake db:migrate RAILS_ENV=production
    bundle exec rake redmine:load_default_data REDMINE_LANG=ja RAILS_ENV=production
    mkdir -p tmp tmp/pdf tmp/pids public/plugin_assets
    sudo chown -R #{redmine_user}:#{redmine_user} files log tmp public/plugin_assets
    sudo chmod -R 755 files log tmp public/plugin_assets
  EOL
end

bash 'set unicorn' do
  user "#{redmine_user}"
  code <<-EOL
    if ! grep unicorn /var/www/redmine-2.5.1/Gemfile; then
      cd /var/www/#{source_dir}
      source ~/.bash_profile
      echo "\ngem 'unicorn'" >> /var/www/#{source_dir}/Gemfile
      bundle install --without development test
      rbenv rehash
    fi
  EOL
end

bash 'create unicorn dir' do
  user "#{redmine_user}"
  not_if 'test -e /etc/unicorn'
  code <<-EOL
    mkdir -p /etc/unicorn
  EOL
end

template "/var/www/#{source_dir}/config/unicorn.rb" do
  user "#{redmine_user}"
  source 'unicorn.rb.erb'

  variables ({
    :port => "#{port}"
  })
end

template "/etc/unicorn/redmine.conf" do
  user 'root'
  source 'redmine.conf.erb'

  variables ({
    :user => "#{redmine_user}",
    :source_dir => "#{source_dir}",
    :ruby_version => "#{ruby_version}"
  })
end

template "/etc/init.d/redmine" do
  user 'root'
  mode 655
  source 'redmine_initd.erb'

  variables ({
    :source_dir => "#{source_dir}",
    :ruby_version => "#{ruby_version}"
  })
end

service 'redmine' do
  action [:start, :enable]
end

