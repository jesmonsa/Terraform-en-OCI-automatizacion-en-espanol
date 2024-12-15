# Setup FSS on Webserver1
resource "null_resource" "produccionWebserver1SharedFilesystem" {
  depends_on = [oci_core_instance.produccionWebserver1, oci_core_instance.produccionBastionServer, oci_file_storage_export.produccionExport]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      script_path         = "/home/opc/myssh.sh"
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '== Start of null_resource.produccionWebserver1SharedFilesystem'",
      "sudo /bin/su -c \"dnf install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /sharedfs\"",
      "sudo /bin/su -c \"echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /sharedfs\"",
      "echo '== End of null_resource.produccionWebserver1SharedFilesystem'"
    ]
  }
}

# Attachment of block volume to Webserver1
resource "null_resource" "produccionWebserver1_oci_iscsi_attach" {
  depends_on = [oci_core_volume_attachment.produccionWebserver1BlockVolume100G_attach]

  # Remove any previous version of the script
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = ["sudo /bin/su -c \"rm -Rf /home/opc/iscsiattach.sh\""]
  }

  # Upload the updated script
  provisioner "file" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    source      = "iscsiattach.sh"
    destination = "/home/opc/iscsiattach.sh"
  }

  # Execute the script
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "sudo /bin/su -c \"chown root /home/opc/iscsiattach.sh\"",
      "sudo /bin/su -c \"chmod u+x /home/opc/iscsiattach.sh\"",
      "sudo /bin/su -c \"/home/opc/iscsiattach.sh > /home/opc/iscsiattach.log 2>&1\""
    ]
  }
}

# Mount of attached block volume on Webserver1
resource "null_resource" "produccionWebserver1_oci_u01_fstab" {
  depends_on = [null_resource.produccionWebserver1_oci_iscsi_attach]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver1_VNIC1.private_ip_address
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      agent               = false
      timeout             = "10m"
      bastion_host        = data.oci_core_vnic.produccionBastionServer_VNIC1.public_ip_address
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
    }
    inline = [
      "echo '== Start of null_resource.produccionWebserver1_oci_u01_fstab'",
      "sudo -u root parted /dev/sdb --script -- mklabel gpt",
      "sudo -u root parted /dev/sdb --script -- mkpart primary ext4 0% 100%",
      "sudo -u root mkfs.ext4 -F /dev/sdb1",
      "sudo -u root mkdir /u01",
      "sudo -u root mount /dev/sdb1 /u01",
      "sudo /bin/su -c \"echo '/dev/sdb1              /u01  ext4    defaults,noatime,_netdev    0   0' >> /etc/fstab\"",
      "sudo -u root mount | grep sdb1",
      "echo '== End of null_resource.produccionWebserver1_oci_u01_fstab'"
    ]
  }
}