packer {
  required_version = ">= 1.8.0"
}

locals {
  preseed = {
    username      = var.ssh_username
    password      = var.ssh_password
    root_password = var.root_password
  }
  ssh_public_key = file(var.ssh_public_key_path)
  build_time     = formatdate("YYYY-MM-DD", timestamp())
}

source "qemu" "debian_base" {
  vm_name          = var.vm_name
  headless         = var.headless
  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"

  iso_url      = var.iso_url
  iso_checksum = var.iso_checksum

  cpus      = 2
  disk_size = "10000"
  memory    = 1024
  qemuargs = [
    ["-m", "1024M"],
    ["-bios", "bios-256k.bin"],
  ]

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_private_key_file = var.ssh_private_key_path
  ssh_port             = 22
  ssh_wait_timeout     = "3600s"

  http_content = {
    "/preseed.cfg" = templatefile("${path.root}/http/preseed.pkrtpl", local.preseed)
  }
  boot_wait    = "5s"
  boot_command = ["<esc><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><enter><wait>"]
}

build {
  name    = "debian_base"
  sources = ["source.qemu.debian_base"]

  # vagrant setup
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts = [
      "${path.root}/bin/vagrant.sh",
      "${path.root}/bin/minimize.sh"
    ]
    expect_disconnect = true
  }

  post-processors {
    post-processor "vagrant" {
      output = "${path.root}/../builds/boxes/${build.name}.{{ .Provider }}.${local.build_time}.box"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = "${path.root}/../builds/boxes/${build.name}.{{ .ChecksumType }}"
    }

    /* post-processor "shell-local" { */
    /*   script = "${path.root}/../../update_catalog.py" */
    /*   execute_command = [ */
    /*     "{{ .Script }}", */
    /*     "-f ${path.root}/../../builds/debian-base.json", */
    /*     "-v=${var.version}", */
    /*     "-p=libvirt", */
    /*     "-b ${path.root}/../../builds/boxes/${build.name}.libvirt.${local.build_time}.box", */
    /*     "-t=sha256", */
    /*     "-c file://${path.root}/../../builds/boxes/${build.name}.sha256", */
    /*   ] */
    /* } */
  }
}
