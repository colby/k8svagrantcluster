# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = [
  { :name => 'm1', :ip => '10.10.3.10', :sync => true, :roles => %w(docker kubernetes keepalived), },
  { :name => 'm2', :ip => '10.10.3.11', :sync => true, :roles => %w(docker kubernetes keepalived), },
  { :name => 's1', :ip => '10.10.3.20', :roles => %w(docker kubernetes), },
  { :name => 's2', :ip => '10.10.3.21', :roles => %w(docker kubernetes), }
]

Vagrant.configure(2) do |config|
  config.vm.provider 'virtualbox' do |vm|
    vm.linked_clone     = true
    vm.default_nic_type = 'virtio'
    vm.customize        [ 'modifyvm', :id, '--uartmode1', 'disconnected' ]
    vm.memory           = 2024
    vm.cpus             = 2
  end

  config.vm.box = 'ubuntu/bionic64'
  # config.vm.box = 'ubuntu/xenial64'

  # NOTE: silence motd
  config.vm.provision 'shell', inline: 'chmod -fR -x /etc/update-motd.d /usr/share/landscape/landscape-sysinfo.wrapper'

  nodes.each do |node|
    config.vm.define node[:name] do |n|
      n.vm.network 'private_network', ip: node[:ip]
      n.vm.synced_folder 'manifests', '/manifests' if node[:sync]
      n.vm.hostname = node[:name]
      n.vm.provision 'chef_solo' do |chef|
	node[:roles].each { |role| chef.add_recipe role }
      end
    end
  end
end
