#
# Cookbook Name:: orientdb
# Recipe:: default
#
# Copyright 2018, GreenSky, LLC
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'apt' if platform_family?('debian')
include_recipe 'yum' if platform_family?('rhel')
include_recipe 'java'
include_recipe 'tar'

# Stop Old OrientDB Service.
# - Only if there is an init script to support a stop command.
service 'orientdb_old' do
  service_name 'orientdb'
  action [:stop, :disable]
  supports status: true, start: true, stop: true
  only_if { ::File.exist?(node['orientdb']['init_script']) }
end

include_recipe 'orientdb::user'
include_recipe 'orientdb::structure'
include_recipe 'orientdb::resources'
include_recipe 'orientdb::scripts'
include_recipe 'orientdb::configuration'

# Fix the orientdb.sh script
template 'orientdb.sh' do
  source "node['orientdb']['installation_directory']/bin/orientdb_sh.erb"
  owner node['orientdb']['user']['id']
  group node['orientdb']['user']['id']
  mode '0755'
  action :create
end
# Start the new OrientDB Service.
service 'orientdb_new' do
  service_name 'orientdb'
  init_command "#{node['orientdb']['installation_directory']}/bin/orientdb.sh"
  start_command "#{node['orientdb']['installation_directory']}/bin/server.sh"
  restart_command "#{node['orientdb']['installation_directory']}/bin/shutdown.sh && #{node['orientdb']['installation_directory']}/bin/server.sh"
  stop_command "#{node['orientdb']['installation_directory']}/bin/shutdown.sh"
  supports status: true, start: true, stop: true
  action [:enable, :start]
end
# service 'orientdb_new' do
#   service_name 'orientdb'
#   supports status: true, start: true, stop: true
#   action [:start, :enable]
# end
