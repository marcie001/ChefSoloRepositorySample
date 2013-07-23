# -*- encoding: utf-8 -*-
# Cookbook Name:: postgresql
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

remote_file "#{Chef::Config[:file_cache_path]}/pgdg-centos92-9.2-6.noarch.rpm" do
  source "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm"
  not_if "rpm -qa | grep -q '^pgdg-centos92-9.2'"
  notifies :install, "rpm_package[pgdg-centos92]", :immediately
end

rpm_package "pgdg-centos92" do
  source "#{Chef::Config[:file_cache_path]}/pgdg-centos92-9.2-6.noarch.rpm"
  only_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/pgdg-centos92-9.2-6.noarch.rpm") }
  action :install
end

file "pgdg-centos92-cleanup" do
  path "#{Chef::Config[:file_cache_path]}/pgdg-centos92-9.2-6.noarch.rpm"
  action :delete
end

package 'postgresql92-server' do
  action :install
end

package 'postgresql92-contrib' do
  action :install
end

package 'postgresql92-devel' do
  action :install
end

execute "/sbin/service postgresql-9.2 initdb" do
  not_if { ::FileTest.exist?("/var/lib/pgsql/9.2/data/PG_VERSION") }
end

template 'pg_hba.conf' do
  path '/var/lib/pgsql/9.2/data/pg_hba.conf'
  owner 'postgres'
  group 'postgres'
  mode '0600'
  variables :method => node['postgresql']['local_authentication']
  notifies :reload, 'service[postgresql-9.2]'
end

template 'postgresql.conf' do
  path '/var/lib/pgsql/9.2/data/postgresql.conf'
  owner 'postgres'
  group 'postgres'
  mode '0600'
  variables :conf => node['postgresql']
  notifies :reload, 'service[postgresql-9.2]'
end

service 'postgresql-9.2' do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

node['postgresql']['users'].each do |id, u|
  options = []
  options << "PASSWORD '#{u['password']}'" if u['password']
  options << "CREATEDB" if u['createdb']
  options << "CREATEROLE" if u['createrole']
  options << "SUPERUSER" if u['superuser']
  options << "LOGIN" if u['login']
  sql = "CREATE ROLE #{u['name']}"
  sql += " WITH " + options.join(' ') if options.length

  execute 'CREATE ROLE' do
    command "echo \"#{sql}\" | psql"
    user 'postgres'
    #not_if
  end
end

node['postgresql']['tablespaces'].each do |id, u|
  options = []
  options << "OWNER #{u['owner']}" if u['owner']
  options << "LOCATION '#{u['location']}'" if u['location']
  sql = "CREATE TABLESPACE #{u['name']}"
  sql += " " + options.join(' ') if options.length

  execute 'CREATE TABLESPACE' do
    command "echo \"#{sql}\" | psql"
    user 'postgres'
    #not_if
  end
end

node['postgresql']['databases'].each do |id, u|
  options = []
  options << "OWNER=#{u['owner']}" if u['owner']
  options << "TEMPLATE=#{u['template']}" if u['template']
  options << "ENCODING='#{u['encoding']}'" if u['encoding']
  options << "LC_COLLATE='#{u['collate']}'" if u['collate']
  options << "LC_CTYPE='#{u['ctype']}'" if u['ctype']
  options << "TABLESPACE=#{u['tablespace']}" if u['tablespace']
  options << "CONNECTION LIMIT=#{u['conn_limit']}" if u['conn_limit']
  sql = "CREATE DATABASE #{u['name']}"
  sql += " WITH " + options.join(' ') if options.length

  execute 'CREATE DATABASE' do
    command "echo \"#{sql}\" | psql"
    user 'postgres'
    #not_if
  end
end
