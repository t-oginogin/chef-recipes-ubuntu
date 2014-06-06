#
# Cookbook Name:: redmine_backlogs
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

redmine_user = node['redmine_backlogs']['user']
source_url = node['redmine_backlogs']['source_url']
source_dir = node['redmine_backlogs']['redmine_source_dir']
version = node['redmine_backlogs']['version']

service 'redmine' do
  action [:stop, :enable]
end

bash 'gem install' do
  user "#{redmine_user}"
  code <<-EOL
    cd /var/www/#{source_dir}/
    source ~/.bash_profile
    gem install holidays 
    rbenv rehash
  EOL
end

bash 'install backlogs' do
  user "#{redmine_user}"
  code <<-EOL
    cd /var/www/#{source_dir}/
    source ~/.bash_profile
    cd /var/www/#{source_dir}/plugins/
    git clone #{source_url}
    cd redmine_backlogs
    git checkout #{version}
    cd /var/www/#{source_dir}
    bundle update nokogiri
    bundle install --without development test
    rbenv rehash
    bundle exec rake tmp:cache:clear
    bundle exec rake tmp:sessions:clear
    bundle exec rake redmine:backlogs:install story_trackers='1,2,3' task_tracker='Task' RAILS_ENV=production
  EOL
end

service 'redmine' do
  action [:start, :enable]
end

