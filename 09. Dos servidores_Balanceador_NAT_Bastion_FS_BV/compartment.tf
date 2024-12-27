resource "oci_identity_compartment" "produccionCompartment" {
  provider = oci.homeregion
  name = "produccionCompartment"
  description = "produccion Compartment"
  compartment_id = var.compartment_ocid
  
  provisioner "local-exec" {
    command = "sleep 60"
  }
}