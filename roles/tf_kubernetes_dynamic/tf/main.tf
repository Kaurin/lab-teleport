variable "public_key" {
  type        = string
  description = "Location of the public key. For example: `~/.ssh/teleport.pub`"
}

variable "cloud_image" {
  type        = string
  description = "Location of the QCOW2 cloud image. For example: `/home/myuser/Downloads/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2`"
}

variable "login_username" {
  type        = string
  description = "Default login username for the guest virtual machines"
}


locals {
  user_data = {
    "packages" : ["python"]
    "users" : [
      {
        "name" : "${var.login_username}"
        "ssh_authorized_keys" : [file(var.public_key)]
        "sudo" : "ALL=(ALL) NOPASSWD:ALL"
        "groups" : "sudo"
        "shell" : "/bin/bash"
        "lock_passwd" : false
        "plain_text_passwd" : "test123"
      }
    ]
  }
}

module "teleport_lab" {
  # source = "../terraform-libvirt-lab"
  source  = "Kaurin/lab/libvirt"
  version = "0.3.0"

  libvirt_pool_name = "teleport_pool"
  libvirt_pool_dir  = "/var/teleport_pool"
  cloud_image       = var.cloud_image

  libvirt_network_name = "teleport_network"
  bridge_device        = "br0"

  lab_vms = [
    {
      name     = "teleport"
      quantity = 1
      ram      = 2048
      vcpu     = 16
      meta_data = {
        "instance-id" : "teleport",
        "local-hostname" : "teleport"
      }
      user_data = local.user_data
      network_configs = [
        {
          "version" : 2
          "ethernets" : {
            "ens3" : {
              "addresses" : ["192.168.0.160/24"]
              "gateway4" : "192.168.0.1"
              "nameservers" : {
                "addresses" : ["192.168.0.1", "192.168.0.2"]
              }
            }
          }
        }
      ]
    },
    {
      name     = "teleport-kubernetes-dynamic-1"
      quantity = 1
      ram      = 4096
      vcpu     = 16
      meta_data = {
        "instance-id" : "teleport-kubernetes-dynamic-1",
        "local-hostname" : "teleport-kubernetes-dynamic-1"
      }
      user_data = local.user_data
      network_configs = [
        {
          "version" : 2
          "ethernets" : {
            "ens3" : {
              "addresses" : ["192.168.0.210/24"]
              "gateway4" : "192.168.0.1"
              "nameservers" : {
                "addresses" : ["192.168.0.1", "192.168.0.2"]
              }
            }
          }
        }
      ]
    }
  ]
}
