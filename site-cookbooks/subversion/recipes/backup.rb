# -*- encoding:utf-8 -*-
# バックアップクーロンを設定する
# スクリプト自体は /usr/local/script/backup_svnrepos.sh に配置する
directory node['subversion']['backup_directory'] do 
  owner node['subversion']['user']
  group node['subversion']['group']
  mode node['subversion']['mode']
  recursive true
end

backup_script_dir = '/usr/local/script'
directory backup_script_dir do
end

template 'backup_svnrepos.sh' do
  path File.join(backup_script_dir, 'backup_svnrepos.sh')
  mode 00755
end

cron 'crontab backup svn repos' do
  hour 1
  minute 0
  command File.join(backup_script_dir, 'backup_svnrepos.sh')
  user node['subversion']['user']
end
