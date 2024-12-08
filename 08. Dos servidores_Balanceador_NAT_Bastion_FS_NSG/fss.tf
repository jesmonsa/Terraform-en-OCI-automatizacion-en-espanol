# Mount Target

resource "oci_file_storage_mount_target" "produccionMountTarget" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.produccionCompartment.id
  subnet_id           = oci_core_subnet.produccionFSSSubnet.id
  ip_address          = var.MountTargetIPAddress
  display_name        = "produccionMountTarget"
  nsg_ids             = [oci_core_network_security_group.produccionFSSSecurityGroup.id]
}

# Export Set

resource "oci_file_storage_export_set" "produccionExportset" {
  mount_target_id = oci_file_storage_mount_target.produccionMountTarget.id
  display_name    = "produccionExportset"
}

# FileSystem

resource "oci_file_storage_file_system" "produccionFilesystem" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.produccionCompartment.id
  display_name        = "produccionFilesystem"
}

# Export

resource "oci_file_storage_export" "produccionExport" {
  export_set_id  = oci_file_storage_mount_target.produccionMountTarget.export_set_id
  file_system_id = oci_file_storage_file_system.produccionFilesystem.id
  path           = "/sharedfs"

  export_options {
    source                         = var.VCN-CIDR
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
  }

}


