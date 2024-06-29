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
      name     = "kubernetes"
      quantity = 1
      ram      = 4096
      vcpu     = 16
      meta_data = {
        "instance-id" : "kubernetes",
        "local-hostname" : "kubernetes"
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
    },
    {
      name     = "teleport-node-agentless"
      quantity = 2
      ram      = 512
      vcpu     = 1
      meta_data = {
        "instance-id" : "teleport-node-agentless",
        "local-hostname" : "teleport-node-agentless"
      }
      user_data = local.user_data
      network_configs = [
        for num in range(203, 205) : # 203-204, not including 205
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
