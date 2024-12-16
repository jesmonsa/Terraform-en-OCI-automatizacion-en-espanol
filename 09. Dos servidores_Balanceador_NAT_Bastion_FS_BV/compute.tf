# Bastion Compute

resource "oci_core_instance" "FoggyKitchenBastionServer" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenBastionServer"
  shape               = var.Shape
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenBastionSubnet.id
    assign_public_ip = true
  }
}

# WebServer1 Compute

resource "oci_core_instance" "FoggyKitchenWebserver1" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer1"
  shape               = var.Shape
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-1"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    user_data = base64encode(<<-EOF
      #!/bin/bash
      # Actualizar el sistema
      yum update -y
      # Instalar Apache y herramientas necesarias
      yum install -y httpd wget unzip

      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --reload
      
      # Crear página de inicio personalizada
      cat > /var/www/html/index.html <<HTML
      <!DOCTYPE html>
      <html>
      <head>
          <title>Servidor Web 1</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 0; padding: 20px; text-align: center; }
              h1 { color: #333; }
          </style>
      </head>
      <body>
          <h1>Bienvenido al Servidor Web 1</h1>
          <p>Este servidor está siendo gestionado por el balanceador de carga de OCI</p>
          <p>Hostname: $(hostname)</p>
          <p>IP: $(hostname -I | cut -d' ' -f1)</p>
      </body>
      </html>
      HTML
      
      # Asegurar permisos correctos
      chown -R apache:apache /var/www/html
      chmod -R 755 /var/www/html
      
      # Iniciar y habilitar Apache
      systemctl start httpd
      systemctl enable httpd
      
      # Crear archivo de health check
      echo "OK" > /var/www/html/health
      EOF
    )
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}

# WebServer2 Compute

resource "oci_core_instance" "FoggyKitchenWebserver2" {
  availability_domain = var.availablity_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer2"
  shape               = var.Shape
  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }
  fault_domain = "FAULT-DOMAIN-2"
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
    user_data = base64encode(<<-EOF
      #!/bin/bash
      # Actualizar el sistema
      yum update -y
      # Instalar Apache y herramientas necesarias
      yum install -y httpd wget unzip

      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --reload
      
      # Crear página de inicio personalizada
      cat > /var/www/html/index.html <<HTML
      <!DOCTYPE html>
      <html>
      <head>
          <title>Servidor Web 2</title>
          <style>
              body { font-family: Arial, sans-serif; margin: 0; padding: 20px; text-align: center; }
              h1 { color: #333; }
          </style>
      </head>
      <body>
          <h1>Bienvenido al Servidor Web 2</h1>
          <p>Este servidor está siendo gestionado por el balanceador de carga de OCI</p>
          <p>Hostname: $(hostname)</p>
          <p>IP: $(hostname -I | cut -d' ' -f1)</p>
      </body>
      </html>
      HTML
      
      # Asegurar permisos correctos
      chown -R apache:apache /var/www/html
      chmod -R 755 /var/www/html
      
      # Iniciar y habilitar Apache
      systemctl start httpd
      systemctl enable httpd
      
      # Crear archivo de health check
      echo "OK" > /var/www/html/health
      EOF
    )
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}
