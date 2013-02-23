#
# Cookbook Name:: bootstrap-chef-server
# Recipe:: default
#
# Copyright 2013, Twiket Ltd
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, BootStrap)

# Build chef_server cookbook attributes
load_attributes_from_env(node['bootstrap']['type'])

include_recipe "chef-server"

if node['bootstrap']['type'].to_sym == :solr
  include_recipe "bootstrap-chef-server::configure_rabbitmq"
end