#
# Cookbook Name:: git
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "git" do
  action :install
end

bash "add alias" do
  user 'vagrant'

  not_if 'grep log ~/.gitconfig'

  code <<-EOL
    echo '[alias]' >> ~/.gitconfig
    echo "  tr = log --graph --pretty='format:%C(yellow)%h%Creset %s %Cgreen(%an)%Creset %Cred%d%Creset'" >> ~/.gitconfig
  EOL
end
