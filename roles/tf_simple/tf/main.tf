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
  version = "0.2.0"

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
      name     = "teleport-node"
      quantity = 2
      ram      = 512
      vcpu     = 1
      meta_data = {
        "instance-id" : "teleport-node",
        "local-hostname" : "teleport-node"
      }
      user_data = local.user_data
      network_configs = [
        for num in range(201, 203) : # 201-202, not including 203
        {
          "version" : 2
          "ethernets" : {
            "ens3" : {
              "addresses" : ["192.168.0.${num}/24"]
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
