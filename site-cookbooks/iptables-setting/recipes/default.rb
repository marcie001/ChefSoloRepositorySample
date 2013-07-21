#
# Cookbook Name:: iptables-setting
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template 'iptables' do
  path '/etc/sysconfig/iptables'
  notifies :restart, 'service[iptables]'
end

service 'iptables' do
  action :nothing
  supports :restart => true, :reload => false, :status => true
end
