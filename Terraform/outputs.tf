output "vm_names" {
  description = "Names of the created VMs"
  value       = vsphere_virtual_machine.vm[*].name
}

output "vm_ip_addresses" {
  description = "Detected guest IP addresses (populated once VMware Tools reports them)"
  value       = vsphere_virtual_machine.vm[*].default_ip_address
}

