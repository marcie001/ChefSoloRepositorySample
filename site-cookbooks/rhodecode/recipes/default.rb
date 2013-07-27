# -*- encoding:utf-8 -*-
# Cookbook Name:: rhodecode
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# virtualenv は使っていない。
# Message Broker もインストールしていない
# 起動もトップページくらいしか確認してない
include_recipe 'python-setuptools'
include_recipe 'rhodecode::python-psycopg2'
include_recipe 'git'

execute 'easy_install rhodecode' do
  user 'root'
  timeout 3600
  creates '/usr/bin/rhodecode-api'
end

directory node['rhodecode']['conf_directory'] do
  owner node['rhodecode']['user']
  group node['rhodecode']['group']
  mode 00755
  recursive true
end

directory node['rhodecode']['repos_directory'] do
  owner node['rhodecode']['user']
  group node['rhodecode']['group']
  mode 00770
  recursive true
end

ini_file = File.join node['rhodecode']['app_directory'], 'production.ini'
template 'production.ini' do
  user node['rhodecode']['user']
  group node['rhodecode']['group']
  mode 00644
  path ini_file
end

execute 'setup rhodecode' do
  conf = node['rhodecode']
  user conf['user']
  group conf['group']
  command "paster setup-rhodecode #{ini_file} --user=#{conf['user']} --password=#{conf['password']} --email=#{conf['email']} --repos=#{conf['repos_directory']} --force-yes"
  only_if { 
    result = %x(echo "select count(*) as count from pg_tables where tablename = 'user_followings'" | sudo -u postgres psql -t rhodecode)
    result.strip === '0'
  }
end

# paster setup-rhodecode 時に filter-with = proxy-prefix が有効になっているとエラーになってしまうので
# あとから書き換えるようにしている
execute 'setup proxy-prefix' do
  conf = node['rhodecode']
  user conf['user']
  group conf['group']
  command "sed -i 's/^#filter-with = proxy-prefix$/filter-with = proxy-prefix/' #{ini_file}"
  action :run
  only_if do
    File.open ini_file do |f|
      result = nil
      f.each_line do |line|
        result = true if /^#filter-with = proxy-prefix$/ =~ line
        break if result
      end
      result
    end
  end
  notifies :restart, 'service[rhodecode]'
end

cron 'make full text search index' do
  command "/usr/bin/paster make-index #{ini_file}"
  user node['rhodecode']['user']
  minute 43
end

directory '/var/log/rhodecode' do
  owner node['rhodecode']['user']
  group node['rhodecode']['group']
  mode 00750
end

template 'rhodecode' do
  path '/etc/init.d/rhodecode'
  mode 00755
end

service 'rhodecode' do
  action [:enable, :start]
  supports :restart => true, :status => true
end
