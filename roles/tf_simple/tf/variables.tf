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
