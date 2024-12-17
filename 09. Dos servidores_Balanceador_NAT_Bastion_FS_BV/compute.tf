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
      
      # Logging
      exec 1> >(logger -s -t $(basename $0)) 2>&1
      
      # Instalar paquetes necesarios
      yum install -y httpd nfs-utils oracle-cloud-agent
      
      # Asegurarse que los servicios necesarios estén iniciados
      systemctl enable nfs-server
      systemctl start nfs-server
      systemctl enable rpcbind
      systemctl start rpcbind
      
      # Crear directorio para el montaje y asignar permisos
      mkdir -p /sharedfs
      chmod 755 /sharedfs
      
      # Intentar montar el FSS varias veces
      max_attempts=5
      attempt=1
      while [ $attempt -le $max_attempts ]; do
        echo "Intento $attempt de $max_attempts para montar NFS..."
        mount -t nfs -o rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 ${var.MountTargetIPAddress}:/sharedfs /sharedfs && break
        attempt=$((attempt+1))
        sleep 10
      done
      
      # Verificar si el montaje fue exitoso
      if ! mount | grep -q "/sharedfs"; then
        echo "Error: Fallo al montar NFS después de $max_attempts intentos"
        exit 1
      fi
      
      # Agregar entrada en fstab
      echo "${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 0 0" >> /etc/fstab
      
      # Configurar SELinux
      setsebool -P httpd_use_nfs 1
      semanage fcontext -a -t httpd_sys_content_t "/sharedfs(/.*)?"
      restorecon -Rv /sharedfs
      
      # Configurar Apache
      cat > /etc/httpd/conf.d/sharedfs.conf <<EOL
      <Directory "/sharedfs">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
      </Directory>
      EOL
      
      # Crear archivo de prueba para health check
      echo "<html><body>OK</body></html>" > /sharedfs/health.html
      echo "<html><body>Welcome to Shared Web Server</body></html>" > /sharedfs/index.html
      
      # Ajustar permisos
      chown -R apache:apache /sharedfs
      chmod -R 755 /sharedfs
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --permanent --add-service=nfs
      firewall-cmd --permanent --add-service=mountd
      firewall-cmd --permanent --add-service=rpc-bind
      firewall-cmd --reload
      
      # Reiniciar Apache para aplicar cambios
      systemctl restart httpd
      systemctl enable httpd
      
      # Verificar que todo esté funcionando
      curl -s http://localhost/sharedfs/health.html || echo "Error: No se puede acceder a health.html"
      df -h | grep sharedfs || echo "Error: No se puede ver el montaje NFS"
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
      
      # Logging
      exec 1> >(logger -s -t $(basename $0)) 2>&1
      
      # Instalar paquetes necesarios
      yum install -y httpd nfs-utils oracle-cloud-agent
      
      # Asegurarse que los servicios necesarios estén iniciados
      systemctl enable nfs-server
      systemctl start nfs-server
      systemctl enable rpcbind
      systemctl start rpcbind
      
      # Crear directorio para el montaje y asignar permisos
      mkdir -p /sharedfs
      chmod 755 /sharedfs
      
      # Intentar montar el FSS varias veces
      max_attempts=5
      attempt=1
      while [ $attempt -le $max_attempts ]; do
        echo "Intento $attempt de $max_attempts para montar NFS..."
        mount -t nfs -o rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 ${var.MountTargetIPAddress}:/sharedfs /sharedfs && break
        attempt=$((attempt+1))
        sleep 10
      done
      
      # Verificar si el montaje fue exitoso
      if ! mount | grep -q "/sharedfs"; then
        echo "Error: Fallo al montar NFS después de $max_attempts intentos"
        exit 1
      fi
      
      # Agregar entrada en fstab
      echo "${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 0 0" >> /etc/fstab
      
      # Configurar SELinux
      setsebool -P httpd_use_nfs 1
      semanage fcontext -a -t httpd_sys_content_t "/sharedfs(/.*)?"
      restorecon -Rv /sharedfs
      
      # Configurar Apache
      cat > /etc/httpd/conf.d/sharedfs.conf <<EOL
      <Directory "/sharedfs">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
      </Directory>
      EOL
      
      # Crear archivo de prueba para health check
      echo "<html><body>OK</body></html>" > /sharedfs/health.html
      echo "<html><body>Welcome to Shared Web Server</body></html>" > /sharedfs/index.html
      
      # Ajustar permisos
      chown -R apache:apache /sharedfs
      chmod -R 755 /sharedfs
      
      # Configurar firewall
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --permanent --add-service=nfs
      firewall-cmd --permanent --add-service=mountd
      firewall-cmd --permanent --add-service=rpc-bind
      firewall-cmd --reload
      
      # Reiniciar Apache para aplicar cambios
      systemctl restart httpd
      systemctl enable httpd
      
      # Verificar que todo esté funcionando
      curl -s http://localhost/sharedfs/health.html || echo "Error: No se puede acceder a health.html"
      df -h | grep sharedfs || echo "Error: No se puede ver el montaje NFS"
    EOF
    )
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}
