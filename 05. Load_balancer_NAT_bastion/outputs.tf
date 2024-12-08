# Bastion Instance Public IP
output "produccionBastionServer_PublicIP" {
  value = [data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address]
}

# LoadBalancer Public IP
output "produccionPublicLoadBalancer_Public_IP" {
  value = [oci_load_balancer.produccionPublicLoadBalancer.ip_address_details[*].ip_address]
}

# WebServer1 Instance Private IP
output "produccionWebserver1PrivateIP" {
  value = [data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address]
}

# WebServer2 Instance Private IP
output "produccionWebserver2PrivateIP" {
  value = [data.oci_core_vnic.produccionWebserver2_VNIC1.private_ip_address]
}

# Generated Private Key for WebServer Instance
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}
