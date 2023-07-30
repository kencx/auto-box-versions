# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = "libvirt"

Vagrant.configure("2") do |config|
  VAGRANT_COMMAND = ARGV[1]

  config.vm.box = "foo/debian"
  config.vm.box_url = "file://./builds/catalog.json"
end
