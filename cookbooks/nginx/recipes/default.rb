#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'nginx' do
  action :install
end

bash 'delete default' do
  user 'root'
  not_if '! test -e /usr/share/nginx'
  code <<-EOL
    rm -rf /usr/share/nginx
    rm /etc/nginx/sites-enabled/default
    rm /etc/nginx/sites-available/default
  EOL
end

service 'nginx' do
  action [:start, :enable]
end
