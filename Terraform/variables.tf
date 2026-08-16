### vSphere connection ###

variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter server FQDN or IP"
  type        = string
}

variable "vsphere_allow_unverified_ssl" {
  description = "Allow self-signed certs (typical for local/lab vCenter)"
  type        = bool
  default     = true
}

### vSphere inventory ###

variable "datacenter" {
  description = "Name of the vSphere datacenter"
  type        = string
}

variable "esxi_host" {
  description = "Name/IP of the standalone ESXi host as registered in vCenter (or in the host's own inventory if connecting directly to ESXi)"
  type        = string
}

variable "datastore" {
  description = "Name of the datastore to place VM disks on"
  type        = string
}

variable "network" {
  description = "Name of the network/port group to attach VMs to"
  type        = string
}

variable "template_name" {
  description = "Name of the source template to clone"
  type        = string
  default     = "packer-ubuntu-22.04"
}

variable "folder" {
  description = "Optional VM folder path inside the datacenter (leave empty for root)"
  type        = string
  default     = ""
}

### VM sizing ###

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 3
}

variable "vm_name_prefix" {
  description = "Prefix used for VM names, e.g. ubuntu-01, ubuntu-02..."
  type        = string
  default     = "ubuntu"
}

variable "num_cpus" {
  description = "Number of vCPUs per VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory per VM in MB"
  type        = number
  default     = 4096
}

variable "disk_size_gb" {
  description = "Primary disk size in GB (must be >= template's disk size)"
  type        = number
  default     = 40
}

### Guest networking ###

variable "domain" {
  description = "DNS domain used for guest customization"
  type        = string
  default     = "local"
}

variable "dns_servers" {
  description = "DNS servers for the guest OS"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "use_dhcp" {
  description = "If true, VMs get IPs via DHCP. If false, static IPs from ip_addresses/gateway are used."
  type        = bool
  default     = true
}

variable "ip_addresses" {
  description = "Static IPs to assign (index-matched to vm_count), only used if use_dhcp = false. CIDR notation, e.g. 192.168.1.101/24"
  type        = list(string)
  default     = []
}

variable "ipv4_gateway" {
  description = "IPv4 gateway, only used if use_dhcp = false"
  type        = string
  default     = ""
}