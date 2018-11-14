# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
# Box / OS
VAGRANT_BOX = 'ubuntu/xenial64'
# Memorable name for your VM
VM_NAME = 'master'
# VM User — 'vagrant' by default
VM_USER = 'vagrant'
# Username on your Machine
G_USER = 'arunendra.chauhan'
# Host folder to sync
HOST_PATH = '/Users/' + G_USER + '/' + VM_NAME
# Where to sync to on Guest — 'vagrant' is the default user name
GUEST_PATH = '/home/' + VM_USER + '/' + VM_NAME
# # VM Port — uncomment this to use NAT instead of DHCP
# VM_PORT = 8080
Vagrant.configure(2) do |config|
  # Vagrant box from Hashicorp
  config.vm.box = VAGRANT_BOX

  # Actual machine name
  config.vm.hostname = VM_NAME
  # Set VM name in Virtualbox
  config.vm.provider :virtualbox do |v|
    v.name = VM_NAME
    v.memory = 5088
  end
  #DHCP — comment this out if planning on using NAT instead
  config.vm.network "public_network"
  # # Port forwarding — uncomment this to use NAT instead of DHCP
  # config.vm.network "forwarded_port", guest: 80, host: VM_PORT
  # Sync folder
  config.vm.synced_folder HOST_PATH, GUEST_PATH
  # Disable default Vagrant folder, use a unique path per project
  config.vm.synced_folder '.', '/home/'+VM_USER+'', disabled: true
  config.vm.provision :shell, path: 'provisions.sh'
end