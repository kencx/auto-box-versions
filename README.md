# Automated Vagrant Box Versioning

This repository is an example of how to automate the versioning of custom Vagrant
boxes.

It utilizes Packer and its `qemu` builder to build a custom Vagrant box from a
Debian ISO. The same can probably be reproduced with the `virtualbox` builder.

Each build produces a box file and checksum in `./builds/boxes`.

```bash
$ cd bases/debian
$ packer build -var-file=auto.pkrvars.hcl .
```

Packer then runs the `update_catalog.py` script to automatically update the
catalog metadata file `builds/catalog.json` with the new version.

To use the new box, add the catalog metadata file as `config.vm.box_url`:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "foo/debian"
  config.vm.box_url = "file://./builds/catalog.json"
end
```

## Setup

1. Install [Vagrant](https://developer.hashicorp.com/vagrant/downloads)
2. Install libvirt

```bash
$ sudo apt install qemu libvirt-daemon-system libvirt-dev ebtables \
    libguestfs-tools ruby-libvirt libvirt-clients bridge-utils
$ sudo adduser [username] kvm
$ sudo adduser [username] libvirt
$ virsh list --all
```

3. Install Vagrant plugins

```bash
$ vagrant plugin install vagrant-libvirt
$ vagrant plugin install vagrant-mutate
```

## Notes

Specify your custom SSH key pair with `ssh_private_key_file` and `ssh_public_key_file`.
The SSH public key will be added to the user's `.ssh/authorized_keys` file.

The default root password is `vagrant`. Although root login is disabled, it is
recommended to change this for non-development systems:

```hcl
# auto.pkrvars.hcl
root_password = changeme
```

or you can choose to change the root password on startup with

```bash
$ sudo passwd root
```

It is also recommended to disable password-less sudo, which has been enabled for
easy provisioning.

## References
- [packer-arch](https://github.com/elasticdog/packer-arch/)
- [bento](https://github.com/chef/bento)
