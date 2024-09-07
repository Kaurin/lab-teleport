# Teleport Lab

The purpose of this lab environment is to give the user a starting point from which they can play around with Teleport.

# Prerequisites

* You know what Teleport is, and its many different ways of being deployed.
* Some terraform knowledge is required
* Some ansible knowledge is required
* General Linux system administrator knowledge

# Overview

TODO


# Requirements

* Host must have libvirt and one of its [virtualization drivers](https://libvirt.org/formatdomain.html#element-and-attribute-overview) available, like KVM
* Host must have passwordless sudo available
* Host must have teleport installed (client only)
* DNS/SSL:
  * If Teleport is accessible from the internet - use the `acme` config in your `teleport.yaml` - TODO not supported at the moment
  * In Teleport won't be accessible from the internet :
    * CloudFlare-hosted domain
    * CloudFlare token for your domain available in the `token.txt` file
    * Your DNS must be one of:
      * Be privately hosted so it intercepts/rewrites `*.your-domain-name.com` to `192.168.0.160`
      * Be on a public DNS that resolves to your public IP which has port `443` port-forwarded to `192.168.0.160`
* Bridged network on the host with the bridge interface under the name `br0`
* Lots of RAM to facilitate virtual machines TODO: how much ram?

# Usage instructions

## One time setup

### Download a Cloud image 

First, check which distribution/versions are supported [here](https://goteleport.com/docs/installation/)

Then download a QEMU/UEFI cloud image. For example Ubuntu Focal (22.04 LTS) can be found as `focal-server-cloudimg-amd64.img` [here](https://cloud-images.ubuntu.com/focal/current/)

### Generate an SSH key for Ansible

```bash
ssh-keygen -f ~/.ssh/teleport_lab -t rsa -b 4096
```

### Sync the python (ansible) dependencies

```bash
pipenv sync
```

### Set up Ansible variables

```bash
mkdir -p group_vars/all
touch group_vars/all/main.yml
```

Edit the `group_vars/all/main.yml` file. You can find the vars that should be overridden in the `inventory/hosts.yml` file.

### Run the acme-lego playbook (once)

This playbook will make the letsencrypt cert available on the workstation host. Reason behind having the cert on the host is that quick iteration of the guest virtual machines doesn't exhaust the letsencrypt rate limits which are pretty harsh.

```bash
pipenv run ansible-playbook local_acme_cert.yml -vv
```

NOTE: Because this playbook stores your certs locally, you won't need to run it again unless you start using a different domain or token. Renewals are handled in the main playbook.

# Iterate

This repo will provide some "archetypal" deployments. They can also be used as starting points so you can create your own.

Here are some of the archetypes:

## Simple

Teleport cluster on a single VM and two SSH nodes

This provisions teleport and should be *mostly* idempotent to run

```bash
pipenv run ansible-playbook main_simple.yml -vv
```

This destroys the environment

```bash
pipenv run ansible-playbook main_simple.yml -vv -e terraform_destroy=true
```

## Kubernetes Dynamic

* Teleport cluster on a single VM,
* k3s VM which is joined via Teleport agent which resides on the same VM.
* The Teleport agent is *not* deployed onto the k3s cluster
* The Teleport agent resides in parallel with the k3s cluster
* Follows (loosely) this teleport document: [Dynamic Kubernetes Cluster Registration](https://goteleport.com/docs/enroll-resources/kubernetes-access/register-clusters/dynamic-registration/) - TODO: make the playbook match the document closer

This provisions teleport and should be *mostly* idempotent to run

```bash
pipenv run ansible-playbook main_kubernetes_dynamic.yml -vv
```

This destroys the environment

```bash
pipenv run ansible-playbook main_kubernetes_dynamic.yml -vv -e terraform_destroy=true
```
