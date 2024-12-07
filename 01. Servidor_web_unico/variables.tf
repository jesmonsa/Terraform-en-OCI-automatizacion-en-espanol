# All variables used by the automation.

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
  description = "The OCID of the compartment."
}

variable "region" {
  description = "The region where the resources will be created."
}

variable "availablity_domain_name" {
  description = "The name of the availability domain."
  default     = ""
}

variable "VCN-CIDR" {
  description = "The CIDR block for the VCN."
  default     = "10.0.0.0/16"
}

variable "Subnet-CIDR" {
  description = "The CIDR block for the subnet."
  default     = "10.0.1.0/24"
}

variable "Shape" {
  description = "The shape of the compute instance."
  default     = "VM.Standard.E5.Flex"
}

variable "FlexShapeOCPUS" {
  description = "The number of OCPUs for flexible shapes."
  default     = 1
  validation {
    condition     = var.FlexShapeOCPUS > 0
    error_message = "The number of OCPUs must be greater than 0."
  }
}

variable "FlexShapeMemory" {
  description = "The amount of memory (in GB) for flexible shapes."
  default     = 2
  validation {
    condition     = var.FlexShapeMemory > 0
    error_message = "The amount of memory must be greater than 0."
  }
}

variable "instance_os" {
  description = "The operating system for the instance."
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "The version of the Linux operating system."
  default     = "8"
}

variable "service_ports" {
  description = "The list of service ports to be opened."
  default     = [80, 443, 22]
}

# Dictionary Locals
locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.E5.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

# Checks if is using Flexible Compute Shapes
locals {
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
}
