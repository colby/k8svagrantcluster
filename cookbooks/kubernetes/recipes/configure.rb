#
# Cookbook Name:: kubernetes
# Recipe:: configure
#

# NOTE: kubelet wants to use enp0s3, we want to use enp0s8
# https://github.com/kubernetes/kubernetes/issues/44702
file '/etc/default/kubelet' do
  content "KUBELET_EXTRA_ARGS=--node-ip=#{node['network']['interfaces']['enp0s8']['addresses'].keys[1]}"
  notifies :restart, 'service[kubelet]', :immediately
end

group node['kubernetes']['group']

user node['kubernetes']['user'] do
  gid         node['kubernetes']['group']
  shell       '/bin/bash'
  home        "/home/#{node['kubernetes']['user']}"
  manage_home true
  action      :create
end

package 'bash-completion'

execute 'kubectl completion bash > /etc/bash_completion.d/kubectl' do
  creates '/etc/bash_completion.d/kubectl'
end

execute 'turn off swap' do
  command 'swapoff -a'
  # NOTE: test if command returns any swap files currently on
  only_if 'test -n "$(swapon --noheadings)"'
end

execute 'disable swap on boot' do
  command 'sed -i \'/ swap / s/^/#/\' /etc/fstab'
  # NOTE: comment out any active swap files from fstab
  only_if 'grep swap /etc/fstab | grep ^[^#]'
end
