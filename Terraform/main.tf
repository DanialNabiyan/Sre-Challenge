data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_host" "host" {
  name          = var.esxi_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm" {
  count = var.vm_count

  name             = format("%s-%02d", var.vm_name_prefix, count.index + 1)
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  host_system_id   = data.vsphere_host.host.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.folder != "" ? var.folder : null

  num_cpus = var.num_cpus
  memory   = var.memory
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = var.disk_size_gb
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("%s-%02d", var.vm_name_prefix, count.index + 1)
        domain    = var.domain
      }

      network_interface {
        ipv4_address = var.use_dhcp ? null : element(split("/", var.ip_addresses[count.index]), 0)
        ipv4_netmask = var.use_dhcp ? null : tonumber(element(split("/", var.ip_addresses[count.index]), 1))
      }

      ipv4_gateway     = var.use_dhcp ? null : var.ipv4_gateway
      dns_server_list  = var.dns_servers
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
    ]
  }
}