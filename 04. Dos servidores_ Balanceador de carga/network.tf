# VCN
resource "oci_core_virtual_network" "produccionVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "produccionVCN"
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "produccionDhcpOptions1" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  vcn_id         = oci_core_virtual_network.produccionVCN.id
  display_name   = "produccionDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["produccion.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "produccionInternetGateway" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionInternetGateway"
  vcn_id         = oci_core_virtual_network.produccionVCN.id
}

# Route Table
resource "oci_core_route_table" "produccionRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  vcn_id         = oci_core_virtual_network.produccionVCN.id
  display_name   = "produccionRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.produccionInternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "produccionSecurityList" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionSecurityList"
  vcn_id         = oci_core_virtual_network.produccionVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}

# Subnet
resource "oci_core_subnet" "produccionWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "produccionWebSubnet"
  dns_label         = "produccionN1"
  compartment_id    = oci_identity_compartment.produccionCompartment.id
  vcn_id            = oci_core_virtual_network.produccionVCN.id
  route_table_id    = oci_core_route_table.produccionRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.produccionDhcpOptions1.id
  security_list_ids = [oci_core_security_list.produccionSecurityList.id]
}
