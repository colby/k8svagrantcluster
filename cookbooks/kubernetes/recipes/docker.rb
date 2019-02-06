#
# Cookbook Name:: kubernetes
# Recipe:: docker
#

apt_package node['docker']['packages']

service 'docker' do
  action [:start, :enable]
end

# NOTE: private docker registry on host is not running HTTPS
file '/etc/docker/daemon.json' do
  content '{ "insecure-registries" : ["10.10.3.1:5000"] }'
  notifies :restart, 'service[docker]', :immediately
end

sysctls = {
  # NOTE: pass bridged IPv4/6 traffic to iptables chains
  'net.bridge.bridge-nf-call-ip6tables' => 1,
  'net.bridge.bridge-nf-call-iptables' => 1,
  # NOTE: docker sets this already, containerd does not
  'net.ipv4.ip_forward' => 1
}

sysctls.each do |key, val|
  sysctl key do
    value val
  end
end
