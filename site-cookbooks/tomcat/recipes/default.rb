#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'build-essential'

group node['tomcat']['user']['group'] do
end

user node['tomcat']['user']['name'] do
  home node['tomcat']['user']['home']
  shell node['tomcat']['user']['shell']
  group node['tomcat']['user']['group']
end

version = node['tomcat']['version']
major_version = version.split('.')[0]
tar_name = "apache-tomcat-#{version}.tar.gz"
remote_file "/usr/local/src/#{tar_name}" do
  source "http://archive.apache.org/dist/tomcat/tomcat-#{major_version}/v#{version}/bin/#{tar_name}"
  owner node['tomcat']['user']['name']
  group node['tomcat']['user']['group']
  mode 0644
  action :create_if_missing
  notifies :run, "script[install #{tar_name}]", :immediately
end

script "install #{tar_name}" do 
  interpreter 'bash'
  user 'root'
  cwd '/usr/local/src'
  code <<"SCRIPT"
if [ -d #{node['tomcat']['directory']} ]; then
    rm -rf #{node['tomcat']['directory']}
fi
tar xf #{tar_name}
mv #{tar_name.gsub '.tar.gz', ''} #{node['tomcat']['directory']}
chown -R #{node['tomcat']['user']['name']}:#{node['tomcat']['user']['group']} #{node['tomcat']['directory']}
chmod g+ws #{File::join node['tomcat']['directory'], 'webapps'}
chmod a+x #{File::join node['tomcat']['directory'], 'bin/daemon.sh'}

cd #{File::join node['tomcat']['directory'], 'bin'}
sudo -u #{node['tomcat']['user']['name']} tar xf commons-daemon-native.tar.gz
cd `find . -type d -regex "./commons-daemon-1.0.[0-9']+-native-src"`/unix
sudo -u #{node['tomcat']['user']['name']} ./configure --with-java=#{node['java']['java_home']}
sudo -u #{node['tomcat']['user']['name']} make
sudo -u #{node['tomcat']['user']['name']} cp jsvc ../..
SCRIPT

  action :nothing
end

template 'tomcat' do
  path '/etc/init.d/tomcat'
  mode 00755
  notifies :restart, 'service[tomcat]'
end

template 'server.xml' do
  path File.join node['tomcat']['directory'], 'conf/server.xml'
  owner 'tomcat'
  group 'tomcat'
  mode 00600
  notifies :restart, 'service[tomcat]'
end

template 'setenv.sh' do
  path File.join node['tomcat']['directory'], 'bin/setenv.sh'
  owner 'tomcat'
  group 'tomcat'
  mode 00600
  notifies :restart, 'service[tomcat]'
end

service 'tomcat' do
  action [:enable, :start]
  supports :restart => false, :reload => false, :status => false
end
