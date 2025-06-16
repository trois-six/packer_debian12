packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
  }
}

variable "disk_size" {
  type    = number
  default = 10240
}

variable "password" {
  type    = string
  default = "debian"
}

variable "user" {
  type    = string
  default = "debian"
}

source "qemu" "debian12" {
  accelerator       = "kvm"
  boot_command      = ["<esc><wait2s>", "auto ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian12.preseed ", "netcfg/choose_interface=auto ", "netcfg/get_hostname=debian ", "debian-installer/language=fr ", "debian-installer/country=FR ", "debian-installer/locale=fr_FR.UTF-8 ", "debian-installer/keymap=fr(latin9) ", "keymap=fr(latin9) ", "<enter>"]
  boot_wait         = "2s"
  disk_interface    = "virtio"
  disk_size         = "${var.disk_size}"
  format            = "qcow2"
  headless          = false
  http_directory    = "."
  http_port_max     = 8080
  http_port_min     = 8080
  iso_checksum      = "sha256:30ca12a15cae6a1033e03ad59eb7f66a6d5a258dcf27acd115c2bd42d22640e8"
  iso_url           = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso"
  machine_type      = "pc"
  net_device        = "virtio-net"
  output_directory  = "img"
  shutdown_command  = "echo '${var.password}' | sudo -E -S poweroff"
  ssh_host_port_max = 2222
  ssh_host_port_min = 2222
  ssh_password      = "${var.password}"
  ssh_username      = "${var.user}"
  ssh_wait_timeout  = "60m"
  vm_name           = "debian12.qcow2"
}


build {
  sources = ["source.qemu.debian12"]

  provisioner "file" {
    source = "debian.sources"
    destination = "/home/${var.user}/debian.sources"
  }

  provisioner "shell" {
    execute_command = "echo '${var.password}' | {{ .Vars }} sudo -E -S bash '{{ .Path }}'"
    scripts         = ["./debian12.postinstall.sh", "./debian12.cleanup.sh"]
  }

}
