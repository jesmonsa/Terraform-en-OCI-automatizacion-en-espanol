# SSH Key
resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Bastion Server
resource "oci_core_instance" "FoggyKitchenBastionServer" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
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

# WebServer1
resource "oci_core_instance" "FoggyKitchenWebserver1" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer1"
  shape               = var.Shape
  
  freeform_tags = merge(
    local.common_tags,
    {
      role = "webserver"
      server_number = "1"
    }
  )

  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }

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
      
      # Instalar paquetes necesarios
      yum install -y httpd iscsi-initiator-utils nfs-utils
      
      # Configurar servicios
      systemctl enable iscsid
      systemctl start iscsid
      systemctl enable httpd
      systemctl start httpd
      
      # Configurar página web
      cat <<HTML > /var/www/html/index.html
      <!DOCTYPE html>
      <html>
      <head>
          <title>Webserver 1</title>
          <style>
              body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
              h1 { color: #333; }
          </style>
      </head>
      <body>
          <h1>Webserver 1</h1>
          <p>Hostname: $(hostname)</p>
          <p>IP: $(hostname -I | cut -d' ' -f1)</p>
      </body>
      </html>
      HTML
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --reload
      
      # Configurar SELinux para permitir acceso NFS
      setsebool -P httpd_use_nfs 1
      
      # Configurar logs
      mkdir -p /var/log/httpd
      chmod 755 /var/log/httpd
      EOF
    )
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}

# WebServer2
resource "oci_core_instance" "FoggyKitchenWebserver2" {
  availability_domain = var.availablity_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[0]["name"] : var.availablity_domain_name
  compartment_id      = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name        = "FoggyKitchenWebServer2"
  shape               = var.Shape
  
  freeform_tags = merge(
    local.common_tags,
    {
      role = "webserver"
      server_number = "2"
    }
  )

  dynamic "shape_config" {
    for_each = local.is_flexible_shape ? [1] : []
    content {
      memory_in_gbs = var.FlexShapeMemory
      ocpus         = var.FlexShapeOCPUS
    }
  }

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
      
      # Instalar paquetes necesarios
      yum install -y httpd iscsi-initiator-utils nfs-utils
      
      # Configurar servicios
      systemctl enable iscsid
      systemctl start iscsid
      systemctl enable httpd
      systemctl start httpd
      
      # Configurar página web
      cat <<HTML > /var/www/html/index.html
      <!DOCTYPE html>
      <html>
      <head>
          <title>Webserver 2</title>
          <style>
              body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
              h1 { color: #333; }
          </style>
      </head>
      <body>
          <h1>Webserver 2</h1>
          <p>Hostname: $(hostname)</p>
          <p>IP: $(hostname -I | cut -d' ' -f1)</p>
      </body>
      </html>
      HTML
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --reload
      
      # Configurar SELinux para permitir acceso NFS
      setsebool -P httpd_use_nfs 1
      
      # Configurar logs
      mkdir -p /var/log/httpd
      chmod 755 /var/log/httpd
      EOF
    )
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}
