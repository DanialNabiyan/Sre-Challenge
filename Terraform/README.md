# vSphere: Vm provisioning using Terraform`

Create vm using exist template. 

## Files

- `versions.tf` – provider requirements + vSphere provider config
- `variables.tf` – all configurable inputs
- `main.tf` – data sources + `vsphere_virtual_machine` resources
- `outputs.tf` – VM names, IPs
- `terraform.tfvars.example` – copy to `terraform.tfvars` and fill in

## Prerequisites

- Terraform >= 1.5
- Network access to your vCenter server
- The template `packer-ubuntu-22.04` must already exist in the datacenter, with VMware Tools installed (required for guest customization to report IPs / apply hostname)

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your datacenter/cluster/datastore/network names and credentials

terraform init
terraform plan
terraform apply
```

This creates  VMs named `ubuntu-01`, `ubuntu-x` by default (change via `vm_name_prefix` / `vm_count`).

## Notes / things to adjust for your environment

- **Credentials**: better to avoid plaintext in `terraform.tfvars` — export as env vars instead:
  ```bash
  export TF_VAR_vsphere_user="administrator@vsphere.local"
  export TF_VAR_vsphere_password="changeme"
  ```
- **Networking**: defaults to DHCP. For static IPs, set `use_dhcp = false` and provide `ip_addresses` (CIDR notation, one per VM) + `ipv4_gateway` in your tfvars.
- **Disk size**: `disk_size_gb` must be >= the template's own disk size, or the clone will fail.
- **Folder**: leave `folder = ""` to place VMs at the datacenter root, or set a path like `"workloads/test"` (folder must already exist).
