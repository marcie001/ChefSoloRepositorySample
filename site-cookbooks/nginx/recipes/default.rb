#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template 'nginx.repo' do
  path '/etc/yum.repos.d/nginx.repo'
  mode 00644
  owner 'root'
  action :create_if_missing
end

package 'nginx' do
  action :install
end

template 'nginx.conf' do
  path '/etc/nginx/nginx.conf'
  notifies :reload, 'service[nginx]'
end

template 'proxy.conf' do
  path '/etc/nginx/proxy.conf'
  notifies :reload, 'service[nginx]'
end

node['nginx']['servers'].each do |id, server|
  template "site.conf" do
    path "/etc/nginx/conf.d/#{id}.conf"
    variables :server => server
    mode 00644
    notifies :reload, 'service[nginx]'
  end
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
