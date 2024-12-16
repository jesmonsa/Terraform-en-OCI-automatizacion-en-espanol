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
      
      # Instalar paquetes necesarios
      yum install -y httpd nfs-utils oracle-cloud-agent

      # Habilitar y arrancar NFS
      systemctl enable nfs-server
      systemctl start nfs-server
      
      # Crear directorio para el montaje
      mkdir -p /sharedfs
      
      # Configurar el montaje NFS
      mount -t nfs ${var.MountTargetIPAddress}:/sharedfs /sharedfs
      
      # Agregar entrada en fstab para montaje persistente
      echo "${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs defaults,_netdev,noatime,bg,timeo=100,hard,nointr,rsize=1048576,wsize=1048576,tcp 0 0" >> /etc/fstab

      # Configurar SELinux para permitir a Apache acceder al NFS
      setsebool -P httpd_use_nfs 1
      
      # Configurar Apache para servir desde el directorio compartido
      sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/sharedfs"|' /etc/httpd/conf/httpd.conf
      
      # Agregar configuración de directorio para /sharedfs
      cat >> /etc/httpd/conf/httpd.conf <<EOL
      <Directory "/sharedfs">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
      </Directory>
      EOL
      
      # Crear archivos necesarios en el FSS
      echo "<html><body>OK</body></html>" > /sharedfs/health.html
      echo "<html><body>Welcome to the shared web server</body></html>" > /sharedfs/index.html
      
      # Ajustar permisos
      chown -R apache:apache /sharedfs
      chmod -R 755 /sharedfs
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --reload
      
      # Habilitar y arrancar Apache
      systemctl enable httpd
      systemctl start httpd
      
      # Verificaciones
      if ! mount | grep sharedfs; then
        echo "Error: NFS mount failed" >> /var/log/messages
        exit 1
      fi
      
      if ! systemctl is-active --quiet httpd; then
        echo "Error: Apache failed to start" >> /var/log/messages
        exit 1
      fi
      
      # Verificar que los archivos existen y son accesibles
      if ! curl -s http://localhost/sharedfs/health.html | grep -q "OK"; then
        echo "Error: Health check file not accessible" >> /var/log/messages
        exit 1
      fi
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
      
      # Instalar paquetes necesarios
      yum install -y httpd nfs-utils oracle-cloud-agent

      # Habilitar y arrancar NFS
      systemctl enable nfs-server
      systemctl start nfs-server
      
      # Crear directorio para el montaje
      mkdir -p /sharedfs
      
      # Configurar el montaje NFS
      mount -t nfs ${var.MountTargetIPAddress}:/sharedfs /sharedfs
      
      # Agregar entrada en fstab para montaje persistente
      echo "${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs defaults,_netdev,noatime,bg,timeo=100,hard,nointr,rsize=1048576,wsize=1048576,tcp 0 0" >> /etc/fstab

      # Configurar SELinux para permitir a Apache acceder al NFS
      setsebool -P httpd_use_nfs 1
      
      # Configurar Apache para servir desde el directorio compartido
      sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/sharedfs"|' /etc/httpd/conf/httpd.conf
      
      # Agregar configuración de directorio para /sharedfs
      cat >> /etc/httpd/conf/httpd.conf <<EOL
      <Directory "/sharedfs">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
      </Directory>
      EOL
      
      # Crear archivos necesarios en el FSS
      echo "<html><body>OK</body></html>" > /sharedfs/health.html
      echo "<html><body>Welcome to the shared web server</body></html>" > /sharedfs/index.html
      
      # Ajustar permisos
      chown -R apache:apache /sharedfs
      chmod -R 755 /sharedfs
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --reload
      
      # Habilitar y arrancar Apache
      systemctl enable httpd
      systemctl start httpd
      
      # Verificaciones
      if ! mount | grep sharedfs; then
        echo "Error: NFS mount failed" >> /var/log/messages
        exit 1
      fi
      
      if ! systemctl is-active --quiet httpd; then
        echo "Error: Apache failed to start" >> /var/log/messages
        exit 1
      fi
      
      # Verificar que los archivos existen y son accesibles
      if ! curl -s http://localhost/sharedfs/health.html | grep -q "OK"; then
        echo "Error: Health check file not accessible" >> /var/log/messages
        exit 1
      fi
    EOF
    )
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}
