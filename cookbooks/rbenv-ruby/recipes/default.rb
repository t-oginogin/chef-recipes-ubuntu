#
# Cookbook Name:: rbenv-ruby
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

ruby_version = node['rbenv']['ruby_version']

bash 'install rbenv' do
  user 'vagrant'
  not_if 'test -e ~/.rbenv'
  code <<-EOL
    git clone https://github.com/sstephenson/rbenv.git $HOME/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.bash_profile
    echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
    chown vagrant $HOME/.bash_profile
    chgrp vagrant $HOME/.bash_profile
    source $HOME/.bash_profile
  EOL
end

bash 'install ruby-build' do
  user 'vagrant'
  not_if 'test -e ~/.rbenv/plugins/ruby-build'
  code <<-EOL
    source $HOME/.bash_profile
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build 
  EOL
end

bash 'install ruby' do
  user 'vagrant'
  code <<-EOL
    source $HOME/.bash_profile
    rbenv install #{ruby_version}
    rbenv local #{ruby_version}
    rbenv rehash
  EOL
end
