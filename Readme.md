# Teleport Lab

Terraform/ansible/KVM powered Teleport lab. Batteries not included.

Teleport tagline taken from [https://goteleport.com/](https://goteleport.com/)
> The easiest and most secure way to access and protect all your infrastructure

Broadly speaking: launch the Teleport lab virtual machines using terraform and provision them using Ansible.

* 1 teleport (server) host `192.168.0.160`
* 3 teleport SSH nodes `192.168.0.201` - `192.168.0.203`
* 1 teleport kubernetes node `192.168.0.171`

# Requirements

* Host must have the Fedora Linux OS
  * Why? I think just because of the lego package. Should be easy to work around
* Host must have libvirt and KVM virtualization available
* Host must have passwordless sudo available
* Host must have teleport installed (client only)
* CloudFlare-hosted domain
* CloudFlare token for your dommain available in the `token.txt` file
* Your DNS must either be privately hosted so it intercepts/rewrites `*.{{ domain_name }}` to `192.168.0.160` OR the be on a public DNS that resolves to your private IP which has port `443` port-forwarded to `192.168.0.160`
* Bridged network on the host with the bridge interface under the name `br0`
* Lots of RAM to facilitate virtual machines

# Prepare the terraform.tfvars file

Something like this

```bash
cat > terraform.tfvars <<EOF
public_key  = "~/.ssh/teleport_lab.pub"
cloud_image = "/home/myuser/Downloads/Fedora-Cloud-Base-Generic.x86_64-40-1.14.qcow2"
login_username = "myusername"
EOF
```

NOTE: The `cloud_image` parameter does not support the tilde (`~`) homedir shorthand.

# Stand up the virtual machines

```bash
terraform init
terraform apply
```

# Sync the python (ansible) dependencies

```bash
pipenv sync
```

# Variables

```bash
mkdir -p group_vars/all
touch group_vars/all/main.yml
```

Edit the `group_vars/all/main.yml` file. You can find the vars that should be modified in the `hosts.ini` file.

# Run the acme-lego playbook

This playbook will make the letsencrypt cert available on the local host. Reason behind having the cert on the host is that quick iteration of the guest virtual machines doesn't exhaust the letsencrypt rate limits which are pretty harsh.

```bash
pipenv run ansible-playbook local_acme_cert.yml -vv
```


# Iterate

This provisions teleport and should be idempotent to run

```bash
pipenv run ansible-playbook main.yml -vv
```

Do things with teleport

If things get too broken, just remove the machine(s) that are beyond repair and then

```bash
terraform apply
```

Followed by:

```bash
pipenv run ansible-playbook main.yml -vv
```
