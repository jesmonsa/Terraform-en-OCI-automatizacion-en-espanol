# VCN
resource "oci_core_virtual_network" "FoggyKitchenVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "foggykitchen"
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN"
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

# Route Table for IGW (Balanceador y Bastion)
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

# Route Table for NAT (Servidores Web)
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

# DHCP Options para la VCN
resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenDHCPOptions1"

  # Opciones de búsqueda de dominio
  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  # Opciones de nombre de dominio personalizado
  options {
    type = "SearchDomain"
    search_domain_names = ["foggykitchen.vcn.oraclevcn.com"]
  }
}

# Security List para Servidores Web
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
    source   = var.LBSubnet-CIDR
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP from Load Balancer"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.BastionSubnet-CIDR
    tcp_options {
      min = 22
      max = 22
    }
    description = "Allow SSH from Bastion"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
    tcp_options {
      min = 3260
      max = 3260
    }
    description = "Allow iSCSI from within VCN"
  }
}

# Security List para Bastion
resource "oci_core_security_list" "FoggyKitchenBastionSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenBastionSecurityList"
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
    description = "Allow SSH from Internet"
  }
}

# Security List para Load Balancer
resource "oci_core_security_list" "FoggyKitchenLoadBalancerSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenLoadBalancerSecurityList"
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = var.WebSubnet-CIDR
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP to Web Servers"
  }

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
    description = "Allow responses to clients"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
    description = "Allow HTTP from Internet"
  }
}

# Subnet Web (Privada)
resource "oci_core_subnet" "FoggyKitchenWebSubnet" {
  cidr_block                 = var.WebSubnet-CIDR
  display_name               = "FoggyKitchenWebSubnet"
  dns_label                  = "websubnet"
  compartment_id             = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id                     = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.FoggyKitchenWebSecurityList.id]
  prohibit_public_ip_on_vnic = true
}

# Subnet Load Balancer (Pública)
resource "oci_core_subnet" "FoggyKitchenLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  display_name      = "FoggyKitchenLBSubnet"
  dns_label         = "lbsubnet"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenLoadBalancerSecurityList.id]
}

# Subnet Bastion (Pública)
resource "oci_core_subnet" "FoggyKitchenBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  display_name      = "FoggyKitchenBastionSubnet"
  dns_label         = "bastionsubnet"
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenBastionSecurityList.id]
}
