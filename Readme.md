# Teleport Lab

The purpose of this lab environment is to give the user a starting point from which they can play around with Teleport.

# Overview

Initially, we use terraform to stand up the following virtual machines:
* 1 teleport (server) host `192.168.0.160`
* 3 plain nodes `192.168.0.201` - `192.168.0.203`
* 1 teleport kubernetes cluster/node `192.168.0.171`

Once the virtual machines are provisioned, and `cloud-init` is done setting them up, we then use Ansible to bootstrap our virtual machines.

# What is Teleport?

Tagline taken from [https://goteleport.com/](https://goteleport.com/)
> The easiest and most secure way to access and protect all your infrastructure

Check out their website for a more detailed explanation

# Requirements

* Host must have the Fedora Linux OS
  * Why? I think just because of the lego package. Should be easy to work around
* Host must have libvirt and KVM virtualization available
* Host must have passwordless sudo available
* Host must have teleport installed (client only)
* CloudFlare-hosted domain
* CloudFlare token for your dommain available in the `token.txt` file
* Your DNS must be one of:
  * Be privately hosted so it intercepts/rewrites `*.your-domain-name.com` to `192.168.0.160`
  * Be on a public DNS that resolves to your public IP which has port `443` port-forwarded to `192.168.0.160`
* Bridged network on the host with the bridge interface under the name `br0`
* Lots of RAM to facilitate virtual machines
  * TODO: how much ram?

# Usage instructions

## Download the fedora cloud image

Get the QEMU flavor from [Fedora's cloud website][fedora-cloud]

## Generate an SSH key for Ansible

```bash
ssh-keygen -f ~/.ssh/teleport_lab -t rsa -b 4096
```

## Prepare the terraform.tfvars file

Something like this

```bash
cat > terraform.tfvars <<EOF
public_key  = "~/.ssh/teleport_lab.pub"
cloud_image = "/home/myuser/Downloads/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
login_username = "myusername"
EOF
```

The `cloud_image` parameter does not support the tilde (`~`) homedir shorthand.

`login_username` is the one that will end up provisioned on your virutal machines. Completely arbitrary. Make sure it matches the one in ansible vars later on.

## Stand up the virtual machines

```bash
terraform init
terraform apply
```

## Wait for cloud-init

Wait about 30 - 60 seconds so cloud init finish provisioning. 

## Sync the python (ansible) dependencies

```bash
pipenv sync
```

## Set up Ansible variables

```bash
mkdir -p group_vars/all
touch group_vars/all/main.yml
```

Edit the `group_vars/all/main.yml` file. You can find the vars that should be modified in the `hosts.ini` file.

NOTE: If copying the variables from `hosts.ini`, keep in mind to change the formatting from `ini` to `yaml` style.

## Run the acme-lego playbook (once)

This playbook will make the letsencrypt cert available on the local host. Reason behind having the cert on the host is that quick iteration of the guest virtual machines doesn't exhaust the letsencrypt rate limits which are pretty harsh.

```bash
pipenv run ansible-playbook local_acme_cert.yml -vv
```

NOTE: Because this playbook stores your certs locally, you won't need to run it again unless you start using a different domain or token. Renewals are handled in the main playbook.

## Iterate

This provisions teleport and should be idempotent to run

```bash
pipenv run ansible-playbook main.yml -vv
```

Do things with teleport.

If things get too broken, just remove the machine(s) that are beyond repair and then

```bash
terraform apply
```

Followed by:

```bash
pipenv run ansible-playbook main.yml -vv
```

[fedora-cloud]: https://fedoraproject.org/cloud/download
