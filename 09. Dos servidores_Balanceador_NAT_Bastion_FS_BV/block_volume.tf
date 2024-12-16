# Block Volume Webserver1
resource "oci_core_volume" "FoggyKitchenWebserver1BlockVolume100G" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebserver1 BlockVolume 100G"
  size_in_gbs        = var.volume_size_in_gbs
}

resource "oci_core_volume_attachment" "FoggyKitchenWebserver1BlockVolume100G_attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.FoggyKitchenWebserver1.id
  volume_id       = oci_core_volume.FoggyKitchenWebserver1BlockVolume100G.id
}

# Block Volume Webserver2
resource "oci_core_volume" "FoggyKitchenWebserver2BlockVolume100G" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebserver2 BlockVolume 100G"
  size_in_gbs        = var.volume_size_in_gbs
}

resource "oci_core_volume_attachment" "FoggyKitchenWebserver2BlockVolume100G_attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.FoggyKitchenWebserver2.id
  volume_id       = oci_core_volume.FoggyKitchenWebserver2BlockVolume100G.id
}
