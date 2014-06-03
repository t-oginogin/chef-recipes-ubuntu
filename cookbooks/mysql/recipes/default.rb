#
# Cookbook Name:: mysql 
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

install_dir = '/usr/local/src'

mysql_version = node['mysql']['version']
mysql_password = node['mysql']['password']

package "mysql-server-#{mysql_version}" do
  action :install
end

template '/etc/mysql/my.cnf' do
  source 'my.cnf.erb'
  owner 'root'
  group 'root'
  mode 644
  
  variables ({
    :character_set_server     => node['mysql']['character_set_server'],
  })
end

service 'mysql' do
  action [:start, :enable]
end

bash "secure_install" do
  user "root"
  not_if "mysql -u root -p#{mysql_password} -e 'show databases;'"

  code <<-EOL
    mysql -u root -p --connect-expired-password -e "set password for root@localhost=password('#{mysql_password}');"
    mysql -u root -p#{mysql_password} -e "set password for root@'localhost'=password('#{mysql_password}');"
    mysql -u root -p#{mysql_password} -e "flush privileges;"
  EOL
end

