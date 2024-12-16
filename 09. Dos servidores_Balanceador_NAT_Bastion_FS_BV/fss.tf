# File System
resource "oci_file_storage_file_system" "FoggyKitchenFilesystem" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenFilesystem"
}

# Mount Target
resource "oci_file_storage_mount_target" "FoggyKitchenMountTarget" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  subnet_id           = oci_core_subnet.FoggyKitchenWebSubnet.id
  display_name        = "FoggyKitchenMountTarget"
  hostname_label      = "fileserver"
  ip_address          = var.MountTargetIPAddress
}

# Export Set
resource "oci_file_storage_export_set" "FoggyKitchenExportSet" {
  mount_target_id = oci_file_storage_mount_target.FoggyKitchenMountTarget.id
  display_name    = "FoggyKitchenExportSet"
}

# Export
resource "oci_file_storage_export" "FoggyKitchenExport" {
  export_set_id  = oci_file_storage_export_set.FoggyKitchenExportSet.id
  file_system_id = oci_file_storage_file_system.FoggyKitchenFilesystem.id
  path           = "/sharedfs"
  
  export_options {
    source                         = var.VCN-CIDR
    access                         = "READ_WRITE"
    identity_squash               = "NONE"
    require_privileged_source_port = false
  }
}
