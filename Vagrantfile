# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 4
  end

  # Specify your hostname if you like
  # config.vm.hostname = "name"
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.network "private_network", type: "dhcp"

  #TODO: figure out my ssh config dir to stop having to do this
  config.ssh.config = "./ssh_config"

end
