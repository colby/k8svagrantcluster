# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.provider 'virtualbox' do |v|
    v.linked_clone     = true
    v.default_nic_type = 'virtio'
    v.customize        [ 'modifyvm', :id, '--uartmode1', 'disconnected' ]
    v.memory           = 2024
    v.cpus             = 2
  end

  # config.vm.box = 'ubuntu/bionic64'
  config.vm.box = 'ubuntu/xenial64'

  # NOTE: make the banner shut up
  config.vm.provision 'shell', inline: 'chmod -R -x /etc/update-motd.d'

  config.vm.provision 'chef_solo' do |chef|
    chef.add_recipe 'kubernetes'
  end

  config.vm.define 'm1', primary: true do |n|
    n.vm.network 'private_network', ip: '10.10.3.10'
    n.vm.hostname = 'm1'
    n.vm.synced_folder 'manifests', '/manifests'
  end

  config.vm.define 's1' do |n|
    n.vm.network 'private_network', ip: '10.10.3.11'
    n.vm.hostname = 's1'
  end

  config.vm.define 's2' do |n|
    n.vm.network 'private_network', ip: '10.10.3.12'
    n.vm.hostname = 's2'
  end
end
