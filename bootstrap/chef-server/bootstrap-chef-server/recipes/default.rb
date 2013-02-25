#
# Cookbook Name:: bootstrap-chef-server
# Recipe:: default
#
# Copyright 2013, Twiket Ltd
#
# All rights reserved - Do Not Redistribute
#

::Chef::Recipe.send(:include, BootStrap)

# We support spit ChefInstall (erchef and solr nodes)
# ---------------------------------------------------

# Build chef_server cookbook attributes
load_attributes_from_env(node['bootstrap']['type'])
node.normal['chef-server']['api_fqdn'] = ENV['CHEF_API_FQDN']

include_recipe "chef-server"
include_recipe "bootstrap-chef-server::configure_rabbitmq" if node['bootstrap']['type'].to_sym == :solr