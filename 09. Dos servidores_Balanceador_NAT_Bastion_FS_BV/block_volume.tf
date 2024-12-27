# 100 GB Block Volume
resource "oci_core_volume" "produccionWebserver1BlockVolume100G" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.produccionCompartment.id
  display_name        = "produccionWebserver1 BlockVolume 100G"
  size_in_gbs         = var.volume_size_in_gbs
}

# Attachment of 100 GB Block Volume to Webserver1
resource "oci_core_volume_attachment" "produccionWebserver1BlockVolume100G_attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.produccionWebserver1.id
  volume_id       = oci_core_volume.produccionWebserver1BlockVolume100G.id
}

