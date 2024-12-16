# SSH Key
output "generated_ssh_private_key" {
  value     = tls_private_key.public_private_key_pair.private_key_pem
  sensitive = true
}

# Bastion
output "bastion_public_ip" {
  description = "IP pública del servidor Bastion"
  value       = oci_core_instance.FoggyKitchenBastionServer.public_ip
}

# Load Balancer
output "lb_public_ip" {
  description = "IP pública del Load Balancer"
  value       = oci_load_balancer.FoggyKitchenPublicLoadBalancer.ip_addresses[0]
}

# Web Servers
output "webserver1_private_ip" {
  description = "IP privada del WebServer 1"
  value       = oci_core_instance.FoggyKitchenWebserver1.private_ip
}

output "webserver2_private_ip" {
  description = "IP privada del WebServer 2"
  value       = oci_core_instance.FoggyKitchenWebserver2.private_ip
}

# Instrucciones de conexión
output "instructions" {
  description = "Instrucciones para conectarse a los servidores"
  value = <<EOF

=== Instrucciones de Conexión ===

1. Guarda la clave SSH privada mostrada arriba en un archivo (ej: private_key.pem)
2. Cambia los permisos del archivo: chmod 600 private_key.pem
3. Conéctate al Bastion:
   ssh -i private_key.pem opc@${oci_core_instance.FoggyKitchenBastionServer.public_ip}
4. Desde el Bastion, conéctate a los web servers:
   ssh -i private_key.pem opc@${oci_core_instance.FoggyKitchenWebserver1.private_ip}
   ssh -i private_key.pem opc@${oci_core_instance.FoggyKitchenWebserver2.private_ip}
5. Accede a la aplicación web a través del Load Balancer:
   http://${oci_load_balancer.FoggyKitchenPublicLoadBalancer.ip_addresses[0]}

EOF
}
