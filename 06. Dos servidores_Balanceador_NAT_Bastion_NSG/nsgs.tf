# Web NSG
resource "oci_core_network_security_group" "produccionWebSecurityGroup" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionWebSecurityGroup"
  vcn_id         = oci_core_virtual_network.produccionVCN.id
}

# Web NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "produccionWebSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.produccionWebSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# Web NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "produccionWebSecurityIngressGroupRules" {
  for_each = toset(var.webservice_ports)

  network_security_group_id = oci_core_network_security_group.produccionWebSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

# SSH NSG
resource "oci_core_network_security_group" "produccionSSHSecurityGroup" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionSSHSecurityGroup"
  vcn_id         = oci_core_virtual_network.produccionVCN.id
}

# SSH NSG Egress Rules
resource "oci_core_network_security_group_security_rule" "produccionSSHSecurityEgressGroupRule" {
  network_security_group_id = oci_core_network_security_group.produccionSSHSecurityGroup.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

# SSH NSG Ingress Rules
resource "oci_core_network_security_group_security_rule" "produccionSSHSecurityIngressGroupRules" {
  for_each = toset(var.bastion_ports)

  network_security_group_id = oci_core_network_security_group.produccionSSHSecurityGroup.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = each.value
      min = each.value
    }
  }
}

