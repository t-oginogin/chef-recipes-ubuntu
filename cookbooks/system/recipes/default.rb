#
# Cookbook Name:: system
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

bash 'set localtime' do
  user 'root'
  not_if 'test -e /etc/localtime.old'
  code <<-EOL
    mv /etc/localtime /etc/localtime.old
    ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  EOL
end
