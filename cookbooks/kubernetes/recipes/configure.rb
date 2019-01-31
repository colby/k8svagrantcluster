#
# Cookbook Name:: kubernetes
# Recipe:: configure
#

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

sysctl 'net.bridge.bridge-nf-call-iptables' do
  value 1
end
