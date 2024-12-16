# VCN
resource "oci_core_vcn" "FoggyKitchenVCN" {
  cidr_block     = var.VCN-CIDR
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenVCN"
  dns_label      = "fkvcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenInternetGateway"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
}

# NAT Gateway
resource "oci_core_nat_gateway" "FoggyKitchenNATGateway" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name   = "FoggyKitchenNATGateway"
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
}

# Public Route Table
resource "oci_core_route_table" "FoggyKitchenPublicRouteTable" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenPublicRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway.id
  }
}

# Private Route Table
resource "oci_core_route_table" "FoggyKitchenPrivateRouteTable" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenPrivateRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.FoggyKitchenNATGateway.id
  }
}

# Web Security List
resource "oci_core_security_list" "FoggyKitchenWebSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenWebSecurityList"

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.LBSubnet-CIDR

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.BastionSubnet-CIDR

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Regla para NFS
  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR

    tcp_options {
      min = 2048
      max = 2050
    }
  }

  # Regla para iSCSI
  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR

    tcp_options {
      min = 3260
      max = 3260
    }
  }
}

# LB Security List
resource "oci_core_security_list" "FoggyKitchenLBSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenLBSecurityList"

  egress_security_rules {
    protocol    = "6"
    destination = var.WebSubnet-CIDR

    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }
}

# Bastion Security List
resource "oci_core_security_list" "FoggyKitchenBastionSecurityList" {
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id         = oci_core_vcn.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenBastionSecurityList"

  egress_security_rules {
    protocol    = "6"
    destination = var.WebSubnet-CIDR

    tcp_options {
      min = 22
      max = 22
    }
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

# Web Subnet
resource "oci_core_subnet" "FoggyKitchenWebSubnet" {
  cidr_block        = var.WebSubnet-CIDR
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_vcn.FoggyKitchenVCN.id
  display_name      = "FoggyKitchenWebSubnet"
  dns_label         = "fkwebn"
  security_list_ids = [oci_core_security_list.FoggyKitchenWebSecurityList.id]
  route_table_id    = oci_core_route_table.FoggyKitchenPrivateRouteTable.id
}

# LB Subnet
resource "oci_core_subnet" "FoggyKitchenLBSubnet" {
  cidr_block        = var.LBSubnet-CIDR
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_vcn.FoggyKitchenVCN.id
  display_name      = "FoggyKitchenLBSubnet"
  dns_label         = "fklbn"
  security_list_ids = [oci_core_security_list.FoggyKitchenLBSecurityList.id]
  route_table_id    = oci_core_route_table.FoggyKitchenPublicRouteTable.id
}

# Bastion Subnet
resource "oci_core_subnet" "FoggyKitchenBastionSubnet" {
  cidr_block        = var.BastionSubnet-CIDR
  compartment_id    = oci_identity_compartment.FoggyKitchenCompartment.id
  vcn_id            = oci_core_vcn.FoggyKitchenVCN.id
  display_name      = "FoggyKitchenBastionSubnet"
  dns_label         = "fkbasn"
  security_list_ids = [oci_core_security_list.FoggyKitchenBastionSecurityList.id]
  route_table_id    = oci_core_route_table.FoggyKitchenPublicRouteTable.id
}
