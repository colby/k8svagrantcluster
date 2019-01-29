#
# Cookbook Name:: kubernetes
# Recipe:: install
#

package 'apt-transport-https'

apt_repository 'kubernetes' do
  uri           'https://apt.kubernetes.io/'
  distribution  "kubernetes-#{node['lsb']['codename']}"
  components    ['main']
  key           'https://packages.cloud.google.com/apt/doc/apt-key.gpg'
  action        :add
  cache_rebuild true
end

# NOTE: lock versions to protect against updates, version skew between kube tools is dangerous
apt_package node['kubernetes']['packages'] do
  action [:install, :lock]
end

service 'docker' do
  action [:start, :enable]
end

# NOTE: kubelet will constantly restart prior to kubeadm init
service 'kubelet' do
  action [:start, :enable]
end
