#
# Cookbook Name:: keepalived
# Recipe:: default
#

apt_package node['keepalived']['packages']

template '/etc/keepalived/keepalived.conf' do
  source 'keepalived.conf.erb'
  mode '0644'
  notifies :restart, 'service[keepalived]', :delayed
end

service 'keepalived' do
  action [:start, :enable]
end
