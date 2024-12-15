# OCI Authentication Variables
variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
}

variable "user_ocid" {
  description = "The OCID of the user."
}

variable "fingerprint" {
  description = "The fingerprint for the user's API key."
}

variable "private_key_path" {
  description = "The path to the private key for API access."
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where resources will be created."
}

variable "region" {
  description = "The region where resources will be deployed."
}

# Availability Domain
variable "availablity_domain_name" {
  description = "The name of the availability domain for resource placement."
  default     = ""
}

# Networking Variables
variable "VCN-CIDR" {
  description = "CIDR block for the Virtual Cloud Network (VCN)."
  default     = "10.0.0.0/16"
}

variable "WebSubnet-CIDR" {
  description = "CIDR block for the Web Subnet."
  default     = "10.0.1.0/24"
}

variable "LBSubnet-CIDR" {
  description = "CIDR block for the Load Balancer Subnet."
  default     = "10.0.2.0/24"
}

variable "BastionSubnet-CIDR" {
  description = "CIDR block for the Bastion Subnet."
  default     = "10.0.3.0/24"
}

# Mount Target Variables
variable "MountTargetIPAddress" {
  description = "The IP address for the File Storage Service mount target."
  default     = "10.0.1.25"
}

# Compute Instance Configuration
variable "Shape" {
  description = "The shape of the compute instance."
  default     = "VM.Standard.E4.Flex"
}

variable "FlexShapeOCPUS" {
  description = "The number of OCPUs for flexible shapes."
  default     = 1
}

variable "FlexShapeMemory" {
  description = "The amount of memory (in GBs) for flexible shapes."
  default     = 2
}

variable "instance_os" {
  description = "The operating system for the compute instances."
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "The version of the Linux operating system."
  default     = "8"
}

# Port Configuration
variable "webservice_ports" {
  description = "List of ports for the web service."
  default     = ["80", "443"]
}

variable "bastion_ports" {
  description = "List of ports for the bastion host."
  default     = ["22"]
}

# Load Balancer Configuration
variable "lb_shape" {
  description = "The shape of the load balancer. Options: flexible or fixed shapes."
  default     = "flexible"
}

variable "flex_lb_min_shape" {
  description = "The minimum bandwidth (in Mbps) for a flexible load balancer."
  default     = 10
}

variable "flex_lb_max_shape" {
  description = "The maximum bandwidth (in Mbps) for a flexible load balancer."
  default     = 100
}

# Block Volume Configuration
variable "volume_size_in_gbs" {
  description = "The size of the block volume (in GBs)."
  default     = 100
}

# SSH and Connection Variables
variable "ssh_private_key" {
  description = "Ruta de la llave privada SSH para conectarse a las instancias."
  type        = string
}

variable "instance_ip" {
  description = "Dirección IP pública o privada de la instancia objetivo."
  type        = string
}

# Dictionary Locals
locals {
  # List of supported flexible compute shapes
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Logical Checks
locals {
  # Checks if the selected compute shape is a flexible shape
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
  
  # Checks if the selected load balancer shape is flexible
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}
