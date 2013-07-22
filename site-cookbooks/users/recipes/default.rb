# -*- encoding: utf-8 -*-
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
data_bag('users').each do |id|
  next unless node['users']['includes'].include? id
  u = data_bag_item("users", id)

  # グループ作成
  groups = Array(u['groups'])
  groups.each do |g|
    group g
  end

  # イニシャルグループ
  inigrp = groups[0]

  # ユーザ名
  username = u['name'] || id

  # ユーザ作成
  user username do
    home u['home']
    password u['password']
    shell u['shell']
    gid inigrp
    supports :manage_home => (u.include?('home') && u['home'] != '/dev/null')
  end

  # authorized_keys
  if u.include?('home') && u['home'] != '/dev/null' 
    directory File.join(u['home'], '.ssh') do
      owner username
      group inigrp || username
      mode '0700'
    end

    if u['ssh-keys']
      template 'authorized_keys' do
        path File.join(u['home'], '/.ssh/authorized_keys')
        owner username
        group inigrp || username
        mode '0600'
        variables :ssh_keys => u['ssh-keys']
      end
    end
  end

  # ユーザをグループに追加
  groups.each do |g|
    group g do
      members u['id']
      append true
    end
  end

  # ホームディレクトリの mode
  if u.include?('home') && u['home'] != '/dev/null' && u['mode']
    directory u['home'] do
      mode u['mode']
    end
  end
end
