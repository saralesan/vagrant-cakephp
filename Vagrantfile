# -*- mode: ruby -*-
# vi: set ft=ruby :

localFolder = "/home/sdtorresl/Programming/PHP"
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.network "forwarded_port", guest: 3306, host: 3316, host_ip: "127.0.0.1"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "lamp"
    vb.memory = "1024"
  end
  
  config.vm.provision "shell", path: "boostrap.sh"
  
  # config.vm.synced_folder localFolder, "/var/www/html",
  #   owner: "vagrant", group: "www-data",
  #   :mount_options => ["dmode=755,fmode=755"]
end
