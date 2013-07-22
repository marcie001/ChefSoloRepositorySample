# -*- encoding:utf-8 -*-
# Cookbook Name:: subversion
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# 各ユーザは svn+ssh で Subversion 用ユーザに（作成自体は users クックブックが行う）アクセスする
package 'subversion' do
  action :install
end

directory node['subversion']['repos_directory'] do 
  owner node['subversion']['user']
  group node['subversion']['group']
  mode node['subversion']['mode']
  recursive true
end

include_recipe 'subversion::backup'
