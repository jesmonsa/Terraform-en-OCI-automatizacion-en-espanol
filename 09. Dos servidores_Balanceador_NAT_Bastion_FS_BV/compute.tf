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
      
      # Habilitar logging detallado
      exec 1> >(tee -a /var/log/user_data.log) 2>&1
      set -x
      
      echo "=== Iniciando configuración del servidor web ==="
      
      # Instalar paquetes necesarios
      echo "=== Instalando paquetes ==="
      yum install -y nfs-utils httpd oracle-cloud-agent
      
      # Configurar servicios NFS
      echo "=== Configurando servicios NFS ==="
      systemctl enable rpcbind nfs-server
      systemctl start rpcbind nfs-server
      
      # Crear y configurar directorio compartido
      echo "=== Configurando directorio compartido ==="
      mkdir -p /shared
      chmod 777 /shared
      
      # Esperar a que el mount target esté disponible
      echo "=== Esperando al mount target ==="
      while ! ping -c1 ${var.MountTargetIPAddress} &>/dev/null; do
        echo "Esperando que el mount target ${var.MountTargetIPAddress} esté disponible..."
        sleep 10
      done
      
      # Montar el FSS con reintentos
      echo "=== Montando FSS ==="
      mount_attempts=0
      max_mount_attempts=10
      
      until mount -t nfs -o rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 ${var.MountTargetIPAddress}:/shared /shared || [ $mount_attempts -eq $max_mount_attempts ]; do
        mount_attempts=$((mount_attempts+1))
        echo "Intento $mount_attempts de $max_mount_attempts para montar NFS"
        sleep 30
      done
      
      # Verificar montaje
      if ! mount | grep -q "/shared"; then
        echo "ERROR: Fallo al montar el FSS después de $max_mount_attempts intentos"
        exit 1
      fi
      
      # Configurar fstab
      echo "=== Configurando fstab ==="
      echo "${var.MountTargetIPAddress}:/shared /shared nfs rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 0 0" >> /etc/fstab
      
      # Configurar SELinux
      echo "=== Configurando SELinux ==="
      setsebool -P httpd_use_nfs 1
      semanage fcontext -a -t httpd_sys_content_t "/shared(/.*)?"
      restorecon -Rv /shared
      
      # Crear archivos web
      echo "=== Creando archivos web ==="
      echo "<html><body>OK</body></html>" > /shared/health.html
      echo "<html><body>Welcome to Shared Web Server</body></html>" > /shared/index.html
      
      # Configurar Apache
      echo "=== Configurando Apache ==="
      cat > /etc/httpd/conf.d/shared.conf <<EOL
DocumentRoot "/shared"
<Directory "/shared">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
EOL
      
      # Ajustar permisos
      echo "=== Ajustando permisos ==="
      chown -R apache:apache /shared
      chmod -R 755 /shared
      
      # Configurar firewall
      echo "=== Configurando firewall ==="
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --permanent --add-service=nfs
      firewall-cmd --permanent --add-service=mountd
      firewall-cmd --permanent --add-service=rpc-bind
      firewall-cmd --reload
      
      # Iniciar y habilitar Apache
      echo "=== Iniciando Apache ==="
      systemctl enable httpd
      systemctl restart httpd
      
      # Verificar configuración
      echo "=== Verificando configuración ==="
      curl -v http://localhost/health.html
      df -h | grep shared
      mount | grep shared
      ls -la /shared
      
      echo "=== Configuración completada ==="
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
      
      # Habilitar logging detallado
      exec 1> >(tee -a /var/log/user_data.log) 2>&1
      set -x
      
      echo "=== Iniciando configuración del servidor web ==="
      
      # Instalar paquetes necesarios
      echo "=== Instalando paquetes ==="
      yum install -y nfs-utils httpd oracle-cloud-agent
      
      # Configurar servicios NFS
      echo "=== Configurando servicios NFS ==="
      systemctl enable rpcbind nfs-server
      systemctl start rpcbind nfs-server
      
      # Crear y configurar directorio compartido
      echo "=== Configurando directorio compartido ==="
      mkdir -p /shared
      chmod 777 /shared
      
      # Esperar a que el mount target esté disponible
      echo "=== Esperando al mount target ==="
      while ! ping -c1 ${var.MountTargetIPAddress} &>/dev/null; do
        echo "Esperando que el mount target ${var.MountTargetIPAddress} esté disponible..."
        sleep 10
      done
      
      # Montar el FSS con reintentos
      echo "=== Montando FSS ==="
      mount_attempts=0
      max_mount_attempts=10
      
      until mount -t nfs -o rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 ${var.MountTargetIPAddress}:/shared /shared || [ $mount_attempts -eq $max_mount_attempts ]; do
        mount_attempts=$((mount_attempts+1))
        echo "Intento $mount_attempts de $max_mount_attempts para montar NFS"
        sleep 30
      done
      
      # Verificar montaje
      if ! mount | grep -q "/shared"; then
        echo "ERROR: Fallo al montar el FSS después de $max_mount_attempts intentos"
        exit 1
      fi
      
      # Configurar fstab
      echo "=== Configurando fstab ==="
      echo "${var.MountTargetIPAddress}:/shared /shared nfs rw,bg,hard,nointr,rsize=1048576,wsize=1048576,tcp,actimeo=0,vers=3 0 0" >> /etc/fstab
      
      # Configurar SELinux
      echo "=== Configurando SELinux ==="
      setsebool -P httpd_use_nfs 1
      semanage fcontext -a -t httpd_sys_content_t "/shared(/.*)?"
      restorecon -Rv /shared
      
      # Crear archivos web
      echo "=== Creando archivos web ==="
      echo "<html><body>OK</body></html>" > /shared/health.html
      echo "<html><body>Welcome to Shared Web Server</body></html>" > /shared/index.html
      
      # Configurar Apache
      echo "=== Configurando Apache ==="
      cat > /etc/httpd/conf.d/shared.conf <<EOL
DocumentRoot "/shared"
<Directory "/shared">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
EOL
      
      # Ajustar permisos
      echo "=== Ajustando permisos ==="
      chown -R apache:apache /shared
      chmod -R 755 /shared
      
      # Configurar firewall
      echo "=== Configurando firewall ==="
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --permanent --add-service=nfs
      firewall-cmd --permanent --add-service=mountd
      firewall-cmd --permanent --add-service=rpc-bind
      firewall-cmd --reload
      
      # Iniciar y habilitar Apache
      echo "=== Iniciando Apache ==="
      systemctl enable httpd
      systemctl restart httpd
      
      # Verificar configuración
      echo "=== Verificando configuración ==="
      curl -v http://localhost/health.html
      df -h | grep shared
      mount | grep shared
      ls -la /shared
      
      echo "=== Configuración completada ==="
    EOF
    )
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.FoggyKitchenWebSubnet.id
    assign_public_ip = false
  }
}
