#
# Cookbook Name:: keepalived
# Recipe:: default
#

apt_package node['keepalived']['packages']

template '/etc/keepalived/keepalived.conf' do
  source 'keepalived.conf.erb'
  mode '0644'
  notifies :restart, 'service[keepalived]', :immediately
end

file '/etc/keepalived/check_kubernetes' do
  content '</dev/tcp/127.0.0.1/6443'
  mode '0755'
end

service 'keepalived' do
  action [:start, :enable]
end
