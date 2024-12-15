# Bastion Instance Public IP
output "FoggyKitchenBastionServer_PublicIP" {
  description = "Public IP address of the Bastion server"
  value       = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
}

# Load Balancer Public IP
output "FoggyKitchenPublicLoadBalancer_PublicIP" {
  description = "Public IP address of the Public Load Balancer"
  value       = oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.ip_address
}

# Load Balancer URL
output "FoggyKitchenPublicLoadBalancer_URL" {
  description = "URL to access the Public Load Balancer"
  value       = "http://${oci_load_balancer_load_balancer.FoggyKitchenPublicLoadBalancer.ip_address}/shared/"
}

# WebServer1 Private IP
output "FoggyKitchenWebserver1PrivateIP" {
  description = "Private IP address of WebServer1"
  value       = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.private_ip_address
}

# WebServer2 Private IP
output "FoggyKitchenWebserver2PrivateIP" {
  description = "Private IP address of WebServer2"
  value       = data.oci_core_vnic.FoggyKitchenWebserver2_VNIC1.private_ip_address
}

# Load Balancer Backend Set Details
output "FoggyKitchenBackendSetDetails" {
  description = "Details of the Backend Set associated with the Load Balancer"
  value       = {
    name        = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.name
    policy      = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.policy
    health_path = oci_load_balancer_backendset.FoggyKitchenPublicLoadBalancerBackendset.health_checker[0].url_path
  }
}

# Generated SSH Private Key
output "generated_ssh_private_key" {
  description = "Generated private SSH key for the WebServer instances"
  value       = tls_private_key.public_private_key_pair.private_key_pem
  sensitive   = true
}

# VCN and Subnet CIDRs
output "FoggyKitchenVCN_CIDR" {
  description = "CIDR block of the Virtual Cloud Network"
  value       = var.VCN-CIDR
}

output "FoggyKitchenWebSubnet_CIDR" {
  description = "CIDR block of the Web subnet"
  value       = var.WebSubnet-CIDR
}

output "FoggyKitchenLBSubnet_CIDR" {
  description = "CIDR block of the Load Balancer subnet"
  value       = var.LBSubnet-CIDR
}

# Terraform State Metadata (for debugging)
output "terraform_state_metadata" {
  description = "Metadata about the Terraform workspace"
  value       = {
    module_workspace = terraform.workspace
  }
}
