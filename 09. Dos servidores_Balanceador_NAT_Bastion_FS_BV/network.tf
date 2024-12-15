# VCN
resource "oci_core_virtual_network" "FoggyKitchenVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "foggykitchen"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["foggykitchen.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

# NAT Gateway
resource "oci_core_nat_gateway" "FoggyKitchenNATGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenNATGateway"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

# Route Table for IGW
resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaIGW"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway.id
  }
}

# Route Table for NAT
resource "oci_core_route_table" "FoggyKitchenRouteTableViaNAT" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenRouteTableViaNAT"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenNATGateway.id
  }
}

# Security List for Web Traffic (HTTP/HTTPS and iSCSI)
resource "oci_core_security_list" "FoggyKitchenWebSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenWebSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 3260
      max = 3260
    }
  }
}

# Security List for SSH Access
resource "oci_core_security_list" "FoggyKitchenSSHSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenSSHSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

# WebSubnet (private)
resource "oci_core_subnet" "FoggyKitchenWebSubnet" {
  cidr_block                 = var.WebSubnet-CIDR
  display_name               = "FoggyKitchenWebSubnet"
  dns_label                  = "websubnet"
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id                     = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.FoggyKitchenWebSecurityList.id, oci_core_security_list.FoggyKitchenSSHSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# LoadBalancer Subnet (public)
resource "oci_core_subnet" "FoggyKitchenLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "FoggyKitchenLBSubnet"
  dns_label         = "lbsubnet"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenWebSecurityList.id]
}

# Bastion Subnet (public)
resource "oci_core_subnet" "FoggyKitchenBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "FoggyKitchenBastionSubnet"
  dns_label         = "bastionsubnet"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenSSHSecurityList.id]
}
