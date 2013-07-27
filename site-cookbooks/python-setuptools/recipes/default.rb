#
# Cookbook Name:: python-setuptools
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
%w( python-setuptools python-devel ).each do |p|
  package p do
    action :install
  end
end
