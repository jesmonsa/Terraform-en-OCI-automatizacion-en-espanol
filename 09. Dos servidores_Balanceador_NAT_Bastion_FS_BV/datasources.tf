# Data source para AD
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Data source para región home
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# Data source para imagen OS
data "oci_core_images" "OSImage" {
  compartment_id           = var.compartment_ocid
  operating_system        = var.instance_os
  operating_system_version = var.linux_os_version
  shape                   = var.Shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# Data sources para VNICs
data "oci_core_vnic" "FoggyKitchenWebserver1_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenWebserver1_VNIC1_attach.vnic_attachments.0.vnic_id
}

data "oci_core_vnic" "FoggyKitchenWebserver2_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenWebserver2_VNIC1_attach.vnic_attachments.0.vnic_id
}

data "oci_core_vnic" "FoggyKitchenBastionServer_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenBastionServer_VNIC1_attach.vnic_attachments.0.vnic_id
}

# Data sources para VNIC attachments
data "oci_core_vnic_attachments" "FoggyKitchenWebserver1_VNIC1_attach" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id    = oci_core_instance.FoggyKitchenWebserver1.id
}

data "oci_core_vnic_attachments" "FoggyKitchenWebserver2_VNIC1_attach" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id    = oci_core_instance.FoggyKitchenWebserver2.id
}

data "oci_core_vnic_attachments" "FoggyKitchenBastionServer_VNIC1_attach" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id    = oci_core_instance.FoggyKitchenBastionServer.id
}

# Locals consolidados
locals {
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}
