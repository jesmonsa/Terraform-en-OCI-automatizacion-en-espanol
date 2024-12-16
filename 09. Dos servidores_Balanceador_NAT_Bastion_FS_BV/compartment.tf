resource "oci_identity_compartment" "FoggyKitchenCompartment" {
  provider       = oci.homeregion
  name           = "FoggyKitchenCompartment"
  description    = "FoggyKitchen Compartment for Infrastructure Resources"
  compartment_id = var.compartment_ocid
  
  enable_delete = true  # Permite eliminar el compartment cuando se destruye la infraestructura

  freeform_tags = local.common_tags

  provisioner "local-exec" {
    command = "sleep 60"  # Esperar para asegurar la propagación del compartment
  }

  lifecycle {
    prevent_destroy = false  # Permitir la destrucción del compartment
    ignore_changes = [
      defined_tags,  # Ignorar cambios en defined_tags
    ]
  }
}