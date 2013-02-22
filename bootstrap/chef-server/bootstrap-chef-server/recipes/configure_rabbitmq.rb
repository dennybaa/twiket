ENV['PATH'] = "/opt/chef-server/bin:/opt/chef-server/embedded/bin:#{ENV['PATH']}"

execute "/opt/chef-server/bin/chef-server-ctl start rabbitmq" do
  retries 20
end

execute "/opt/chef-server/embedded/bin/chpst -u #{node["chef_server"]["user"]["username"]} -U #{node["chef_server"]["user"]["username"]} /opt/chef-server/embedded/bin/rabbitmqctl wait /var/opt/chef-server/rabbitmq/db/#{node['chef-server']['configuration']['rabbitmq']['nodename']}.pid" do
  retries 10
end

[ node['chef-server']['configuration']['rabbitmq']['vhost'] ].each do |vhost|
  execute "/opt/chef-server/embedded/bin/rabbitmqctl add_vhost #{vhost}" do
    user node['chef_server']['user']['username']
    not_if "/opt/chef-server/embedded/bin/chpst -u #{node["chef_server"]["user"]["username"]} -U #{node["chef_server"]["user"]["username"]} /opt/chef-server/embedded/bin/rabbitmqctl list_vhosts| grep #{vhost}"
    retries 20
  end
end

# create chef user for the queue
execute "/opt/chef-server/embedded/bin/rabbitmqctl add_user #{node['chef-server']['configuration']['rabbitmq']['user']} #{node['chef-server']['configuration']['rabbitmq']['password']}" do
  not_if "/opt/chef-server/embedded/bin/chpst -u #{node["chef_server"]["user"]["username"]} -U #{node["chef_server"]["user"]["username"]} /opt/chef-server/embedded/bin/rabbitmqctl list_users |grep #{node['chef-server']['configuration']['rabbitmq']['user']}"
  user node['chef_server']['user']['username']
  retries 10
end

# grant the mapper user the ability to do anything with the /chef vhost
# the three regex's map to config, write, read permissions respectively
execute "/opt/chef-server/embedded/bin/rabbitmqctl set_permissions -p #{node['chef-server']['configuration']['rabbitmq']['vhost']} #{node['chef-server']['configuration']['rabbitmq']['user']} \".*\" \".*\" \".*\"" do
  user node['chef_server']['user']['username']
  not_if "/opt/chef-server/embedded/bin/chpst -u #{node["chef_server"]["user"]["username"]} -U #{node["chef_server"]["user"]["username"]} /opt/chef-server/embedded/bin/rabbitmqctl list_user_permissions #node['chef-server']['configuration']['rabbitmq']['user']}|grep #{node['chef-server']['configuration']['rabbitmq']['vhost']}"
  retries 10
end