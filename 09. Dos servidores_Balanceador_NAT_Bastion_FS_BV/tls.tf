resource "tls_private_key" "public_private_key_pair" {
  algorithm   = "RSA"
  rsa_bits    = 4096  # Aumentar la seguridad con 4096 bits

  lifecycle {
    create_before_destroy = true
    prevent_destroy = false  # Permitir regenerar las claves si es necesario
  }
}