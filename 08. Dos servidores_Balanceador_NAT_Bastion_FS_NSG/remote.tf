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
      "echo '== End of null_resource.produccionWebserver2SharedFilesystem'"
    ]
  }

}

# Setup FSS on Webserver2

resource "null_resource" "produccionWebserver2SharedFilesystem" {
  depends_on = [oci_core_instance.produccionWebserver2, oci_core_instance.produccionBastionServer, oci_file_storage_export.produccionExport]

  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = data.oci_core_vnic.produccionWebserver2_VNIC1.private_ip_address
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
      "echo '== Start of null_resource.produccionWebserver2SharedFilesystem'",
      "sudo /bin/su -c \"dnf install -y -q nfs-utils\"",
      "sudo /bin/su -c \"mkdir -p /sharedfs\"",
      "sudo /bin/su -c \"echo '${var.MountTargetIPAddress}:/sharedfs /sharedfs nfs rsize=8192,wsize=8192,timeo=14,intr 0 0' >> /etc/fstab\"",
      "sudo /bin/su -c \"mount /sharedfs\"",
      "echo '== Start of null_resource.produccionWebserver2SharedFilesystem'"
    ]
  }

}

# Software installation within WebServer1 Instance

resource "null_resource" "produccionWebserver1HTTPD" {
  depends_on = [oci_core_instance.produccionWebserver1, oci_core_instance.produccionBastionServer, null_resource.produccionWebserver1SharedFilesystem]
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
    inline = ["echo '== 1. Installing HTTPD package with dnf'",
      "sudo -u root dnf -y -q install httpd",

      "echo '== 2. Creating /sharedfs/index.html'",
      "sudo -u root touch /sharedfs/index.html",
      "sudo /bin/su -c \"echo 'Welcome to produccion.com! These are both WEBSERVERS under LB umbrella with shared index.html ...' > /sharedfs/index.html\"",

      "echo '== 3. Adding Alias and Directory sharedfs to /etc/httpd/conf/httpd.conf'",
      "sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",

      "echo '== 4. Disabling SELinux'",
      "sudo -u root setenforce 0",

      "echo '== 5. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop",
    "sudo -u root service httpd start"]
  }
}

# Software installation within WebServer2 Instance

resource "null_resource" "produccionWebserver2HTTPD" {
  depends_on = [null_resource.produccionWebserver1HTTPD, oci_core_instance.produccionWebserver2, oci_core_instance.produccionBastionServer, null_resource.produccionWebserver2SharedFilesystem]
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
    inline = ["echo '== 1. Installing HTTPD package with dnf'",
      "sudo -u root dnf -y -q install httpd",

      "echo '== 2. Adding Alias and Directory sharedfs to /etc/httpd/conf/httpd.conf'",
      "sudo /bin/su -c \"echo 'Alias /shared/ /sharedfs/' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '<Directory /sharedfs>' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'AllowOverride All' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo 'Require all granted' >> /etc/httpd/conf/httpd.conf\"",
      "sudo /bin/su -c \"echo '</Directory>' >> /etc/httpd/conf/httpd.conf\"",

      "echo '== 3. Disabling SELinux'",
      "sudo -u root setenforce 0",

      "echo '== 4. Disabling firewall and starting HTTPD service'",
      "sudo -u root service firewalld stop",
    "sudo -u root service httpd start"]
  }
}
