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

# Route Table for IGW
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

# NAT Gateway
resource "oci_core_nat_gateway" "produccionNATGateway" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionNATGateway"
  vcn_id         = oci_core_virtual_network.produccionVCN.id
}

# Route Table for NAT
resource "oci_core_route_table" "produccionRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  vcn_id         = oci_core_virtual_network.produccionVCN.id
  display_name   = "produccionRouteTableViaNAT"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.produccionNATGateway.id
  }
}

# Security List for HTTP/HTTPS
resource "oci_core_security_list" "produccionWebSecurityList" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionWebSecurityList"
  vcn_id         = oci_core_virtual_network.produccionVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.webservice_ports
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

# Security List for SSH
resource "oci_core_security_list" "produccionSSHSecurityList" {
  compartment_id = oci_identity_compartment.produccionCompartment.id
  display_name   = "produccionSSHSecurityList"
  vcn_id         = oci_core_virtual_network.produccionVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.bastion_ports
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

# WebSubnet (private)
resource "oci_core_subnet" "produccionWebSubnet" {
  cidr_block                 = var.WebSubnet-CIDR
  display_name               = "produccionWebSubnet"
  dns_label                  = "produccionN2"
  compartment_id             = oci_identity_compartment.produccionCompartment.id
  vcn_id                     = oci_core_virtual_network.produccionVCN.id
  route_table_id             = oci_core_route_table.produccionRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.produccionDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.produccionWebSecurityList.id, oci_core_security_list.produccionSSHSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "produccionLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "produccionLBSubnet"
  dns_label         = "produccionN1"
  compartment_id    = oci_identity_compartment.produccionCompartment.id
  vcn_id            = oci_core_virtual_network.produccionVCN.id
  route_table_id    = oci_core_route_table.produccionRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.produccionDhcpOptions1.id
  security_list_ids = [oci_core_security_list.produccionWebSecurityList.id]
}

# Bastion Subnet (public)
resource "oci_core_subnet" "produccionBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "produccionBastionSubnet"
  dns_label         = "produccionN3"
  compartment_id    = oci_identity_compartment.produccionCompartment.id
  vcn_id            = oci_core_virtual_network.produccionVCN.id
  route_table_id    = oci_core_route_table.produccionRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.produccionDhcpOptions1.id
  security_list_ids = [oci_core_security_list.produccionSSHSecurityList.id]
}



