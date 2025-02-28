# Teleport Lab

The purpose of this repository is to provide  the user with short lived Teleport deployment archetypes to test out various Teleport features.

This is achieved by utilizing libvirt/qemu together with Terraform to stand-up virtual machines, and ansible to provision them.

Ansible roles contained here could (potentially) be used like lego pieces if you are to create your own Teleport deployment playbook. For reference, see this readme and playbooks starting with `main_*`

Teleport deployments created with this repository are not meant for production use.

# Prerequisites

* Linux host which supports qemu virtualization through libvirt
* Lots of RAM to facilitate virtual machines TODO: how much ram?
* Host must have libvirt and one of its [virtualization drivers](https://libvirt.org/formatdomain.html#element-and-attribute-overview) available. KVM for Linux
* Host must have teleport installed for `tsh` / `tctl` use on your workstation
* Bridged network on the host with the bridge interface under the name `br0`
* You know what Teleport is, and some of its many different ways of being deployed.
* Teleport Enterprise. `license.pem` should be placed in the root of this git repository
* DNS and TLS:
  * If this is a public lab (accessible from the internet)
      * Use the `acme` config in your `teleport.yaml`
      * Be on a public DNS that resolves to your public IP which has port `443` port-forwarded to `192.168.0.160` (assuming home lab behind an internet-facing router)
  * If this is a private lab (not accessible from the internet)
    * You will need your own hosted domain
    * Use one of the [lego supported](https://go-acme.github.io/lego/dns/) DNS providers. CloudFlare example is in `inventory/hosts.yml`
      * DNS one of:
        * Privately hosted so it intercepts/rewrites `*.yourdomain.com` to `192.168.0.160`
        * Publicly hosted where it resolves `*.yourdomain.com` and `yourdomain.com` to `192.168.0.160`
        * Hosts file manipulation (No plans to implement- it would require deploying the hosts file on all deployed components and the workstation)
* Some terraform knowledge is required
* Some ansible knowledge is required
* General Linux system administrator knowledge

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

Create/edit the `group_vars/all/main.yml` file. You can find the vars that should be overridden in the `inventory/hosts.yml` file.

### Run the acme-lego playbook (once)

Skip this part if your Teleport environment will be reachable from the internet, and set up `acme` in your `teleport.yaml`.

This playbook will make the letsencrypt cert available on the workstation host. Reason behind having the cert on the host is that quick iteration of the guest virtual machines doesn't exhaust the letsencrypt rate limits which are pretty harsh.

Note: You will get a prompt `BECOME password:`. This is prompting you for your sudo password.
Note: You can set the ansible variable `letsencrypt_working_environment_choice` to `staging` if you want to perform trial runs which have much more relaxed rate limiting.

If your workstation sudo is passwordless

```bash
pipenv run ansible-playbook local_acme_cert.yml -vv
```

If your workstation sudo requires password

```bash
pipenv run ansible-playbook local_acme_cert.yml -vv --ask-become-pass
```

NOTE: Because this playbook stores your certs locally, you won't need to run it again unless you start using a different domain or token. Renewals are handled in the main playbook.

## Iterate using Teleport deployment archetypes

This repo will provide some "archetypal" deployments. They can also be used as starting points so you can create your own. See playbooks starting with `main_*`.

Here are some of the archetypes:

### Simple

Teleport cluster on a single VM and two SSH nodes

This provisions teleport and should be *mostly* idempotent to run

```bash
pipenv run ansible-playbook main_simple.yml -vv
```

This destroys the environment

```bash
pipenv run ansible-playbook main_simple.yml -vv -e terraform_destroy=true
```

### Kubernetes dynamic

* Teleport cluster on a single VM,
* k3s VM:
  * The Teleport agent is *not* deployed onto the k3s cluster
  * The Teleport agent resides in parallel with the k3s cluster on the same VM
  * Joined to the Teleport cluster with type "kube"
* Follows (loosely) this teleport document: [Dynamic Kubernetes Cluster Registration](https://goteleport.com/docs/enroll-resources/kubernetes-access/register-clusters/dynamic-registration/) - TODO: make the playbook match the document closer

This provisions teleport and should be *mostly* idempotent to run

```bash
pipenv run ansible-playbook main_kube_dynamic.yml -vv
```

This destroys the environment

```bash
pipenv run ansible-playbook main_kube_dynamic.yml -vv -e terraform_destroy=true
```

### teleport-cluster deployed on a k3s cluster

This playbook will deploy:
* 1 K3s Cluster which will host `teleport-cluster` and `teleport-kube-agent` helm charts
* 2 K3s Clusters which will host the `teleport-kube-agent` and join the `teleport-cluster` from the bulletpoint above

You can control whether you want an L4 or L7 traefik-based LB (IngressRouteTCP vs IngressRoute respectively).
Use the `helm_teleport_cluster_lb_mode=L4` or `L7`. **Defaults to L4** because it's more performant.

Note:
I also included a HTTPS tightening middleware (L7), and tightened TLSOptions for L7 and L4 deployments.
This is completely irrelevant to Teleport and can be ripped out if needed.

Deploy with:
```bash
pipenv run ansible-playbook main_kube_helm.yml -vv
```

This destroys the environment

```bash
pipenv run ansible-playbook main_kube_helm.yml -vv -e terraform_destroy=true
```
