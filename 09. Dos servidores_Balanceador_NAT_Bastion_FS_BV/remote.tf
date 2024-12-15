# Setup FSS on Webserver1
resource "null_resource" "FoggyKitchenWebserver1SharedFilesystem" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver1, oci_core_instance.FoggyKitchenBastionServer, oci_file_storage_export.FoggyKitchenExport]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '== Configuring Shared Filesystem on Webserver1 =='",

      # Instalar utilidades NFS
      "sudo dnf install -y -q nfs-utils",

      # Crear directorio compartido
      "sudo mkdir -p /sharedfs",

      # Configurar fstab
      "sudo /bin/su -c \"echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",

      # Montar sistema de archivos
      "sudo mount /sharedfs",

      "echo '== Shared Filesystem Configured on Webserver1 =='"
    ]
  }
}

# Attachment of block volume to Webserver1
resource "null_resource" "FoggyKitchenWebserver1_oci_iscsi_attach" {
  depends_on = [oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach]

  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '== Preparing iSCSI Attach Script =='",

      # Validar permisos
      "sudo chmod +x /home/opc/iscsiattach.sh",

      # Validar sintaxis del script
      "sudo /bin/bash -n /home/opc/iscsiattach.sh",

      # Ejecutar script
      "sudo /home/opc/iscsiattach.sh",

      "echo '== iSCSI Attach Completed =='"
    ]
  }
}

# Mount of attached block volume on Webserver1
resource "null_resource" "FoggyKitchenWebserver1_oci_u01_fstab" {
  depends_on = [null_resource.FoggyKitchenWebserver1_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.FoggyKitchenWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.FoggyKitchenBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '== Configuring Block Volume Mount =='",

      # Crear partición y formatear
      "sudo parted /dev/sdb --script -- mklabel gpt",
      "sudo parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo mkfs.ext4 -F /dev/sdb1",

      # Crear punto de montaje
      "sudo mkdir -p /u01",

      # Montar el volumen y agregar a fstab
      "sudo mount /dev/sdb1 /u01",
      "sudo /bin/su -c \"echo '/dev/sdb1 /u01 ext4 defaults,noatime,_netdev 0 0' >> /etc/fstab\"",

      "echo '== Block Volume Mounted on /u01 =='"
    ]
  }
}