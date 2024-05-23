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
        "lock_passwd" : true
      }
    ]
  }
}

module "teleport_lab" {
  # source = "../terraform-libvirt-lab"
  source  = "Kaurin/lab/libvirt"
  version = "0.1.3"

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
          "network" : {
            "version" : 2
            "ethernets" : {
              "eth0" : {
                "addresses" : ["192.168.0.160/24"]
                "gateway4" : "192.168.0.1"
                "nameservers" : {
                  "addresses" : ["192.168.0.1", "192.168.0.2"]
                }
              }
            }
          }
        }
      ]
    },
    {
      name     = "kubernetes-1"
      quantity = 1
      ram      = 4096
      vcpu     = 16
      meta_data = {
        "instance-id" : "kubernetes-1",
        "local-hostname" : "kubernetes-1"
      }
      user_data = local.user_data
      network_configs = [
        {
          "network" : {
            "version" : 2
            "ethernets" : {
              "eth0" : {
                "addresses" : ["192.168.0.171/24"]
                "gateway4" : "192.168.0.1"
                "nameservers" : {
                  "addresses" : ["192.168.0.1", "192.168.0.2"]
                }
              }
            }
          }
        }
      ]
    },
    {
      name     = "teleport_target"
      quantity = 3
      ram      = 1024
      vcpu     = 1
      meta_data = {
        "instance-id" : "teleport_target",
        "local-hostname" : "teleport_target"
      }
      user_data = local.user_data
      network_configs = [
        for num in range(201, 204) : # 201-203, not including 204
        {
          "network" : {
            "version" : 2
            "ethernets" : {
              "eth0" : {
                "addresses" : ["192.168.0.${num}/24"]
                "gateway4" : "192.168.0.1"
                "nameservers" : {
                  "addresses" : ["192.168.0.1", "192.168.0.2"]
                }
              }
            }
          }
        }
      ]
    }
  ]
}
