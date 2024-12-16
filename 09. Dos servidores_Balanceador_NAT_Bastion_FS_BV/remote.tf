# Configuración de remote-exec para WebServer1
resource "null_resource" "FoggyKitchenWebserver1ISCSI" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver1, oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = oci_core_instance.FoggyKitchenWebserver1.private_ip
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = oci_core_instance.FoggyKitchenBastionServer.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo -s bash -c 'iscsiadm -m node -o new -T ${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.iqn} -p ${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.ipv4}:${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.port}'",
      "sudo -s bash -c 'iscsiadm -m node -o update -T ${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.iqn} -n node.startup -v automatic'",
      "sudo -s bash -c 'iscsiadm -m node -T ${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.iqn} -p ${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.ipv4}:${oci_core_volume_attachment.FoggyKitchenWebserver1BlockVolume100G_attach.port} -l'",
      "sudo -s bash -c 'mkfs.xfs /dev/sdb'",
      "sudo -s bash -c 'mkdir -p /u01/app/data'",
      "sudo -s bash -c 'mount /dev/sdb /u01/app/data'",
      "sudo -s bash -c 'echo \"/dev/sdb /u01/app/data xfs defaults,_netdev,nofail 0 2\" >> /etc/fstab'",
    ]
  }
}

# Configuración de remote-exec para WebServer2
resource "null_resource" "FoggyKitchenWebserver2ISCSI" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver2, oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = oci_core_instance.FoggyKitchenWebserver2.private_ip
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = oci_core_instance.FoggyKitchenBastionServer.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo -s bash -c 'iscsiadm -m node -o new -T ${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.iqn} -p ${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.ipv4}:${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.port}'",
      "sudo -s bash -c 'iscsiadm -m node -o update -T ${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.iqn} -n node.startup -v automatic'",
      "sudo -s bash -c 'iscsiadm -m node -T ${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.iqn} -p ${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.ipv4}:${oci_core_volume_attachment.FoggyKitchenWebserver2BlockVolume100G_attach.port} -l'",
      "sudo -s bash -c 'mkfs.xfs /dev/sdb'",
      "sudo -s bash -c 'mkdir -p /u01/app/data'",
      "sudo -s bash -c 'mount /dev/sdb /u01/app/data'",
      "sudo -s bash -c 'echo \"/dev/sdb /u01/app/data xfs defaults,_netdev,nofail 0 2\" >> /etc/fstab'",
    ]
  }
}

# Configuración de FSS para WebServer1
resource "null_resource" "FoggyKitchenWebserver1FSS" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver1, oci_file_storage_export.FoggyKitchenExport]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = oci_core_instance.FoggyKitchenWebserver1.private_ip
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = oci_core_instance.FoggyKitchenBastionServer.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo -s bash -c 'yum install -y nfs-utils'",
      "sudo -s bash -c 'mkdir -p /sharedfs'",
      "sudo -s bash -c 'mount ${oci_file_storage_mount_target.FoggyKitchenMountTarget.ip_address}:/sharedfs /sharedfs'",
      "sudo -s bash -c 'echo \"${oci_file_storage_mount_target.FoggyKitchenMountTarget.ip_address}:/sharedfs /sharedfs nfs defaults,_netdev,nofail 0 2\" >> /etc/fstab'",
    ]
  }
}

# Configuración de FSS para WebServer2
resource "null_resource" "FoggyKitchenWebserver2FSS" {
  depends_on = [oci_core_instance.FoggyKitchenWebserver2, oci_file_storage_export.FoggyKitchenExport]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = oci_core_instance.FoggyKitchenWebserver2.private_ip
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = oci_core_instance.FoggyKitchenBastionServer.public_ip
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo -s bash -c 'yum install -y nfs-utils'",
      "sudo -s bash -c 'mkdir -p /sharedfs'",
      "sudo -s bash -c 'mount ${oci_file_storage_mount_target.FoggyKitchenMountTarget.ip_address}:/sharedfs /sharedfs'",
      "sudo -s bash -c 'echo \"${oci_file_storage_mount_target.FoggyKitchenMountTarget.ip_address}:/sharedfs /sharedfs nfs defaults,_netdev,nofail 0 2\" >> /etc/fstab'",
    ]
  }
}