# Variables requeridas para el provider
variable "tenancy_ocid" {
  description = "OCID del tenancy"
  type        = string

  validation {
    condition     = can(regex("^ocid1.tenancy.", var.tenancy_ocid))
    error_message = "El OCID del tenancy debe comenzar con 'ocid1.tenancy.'"
  }
}

variable "user_ocid" {
  description = "OCID del usuario"
  type        = string

  validation {
    condition     = can(regex("^ocid1.user.", var.user_ocid))
    error_message = "El OCID del usuario debe comenzar con 'ocid1.user.'"
  }
}

variable "fingerprint" {
  description = "Fingerprint de la clave API"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada API"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID del compartment"
  type        = string

  validation {
    condition     = can(regex("^ocid1.compartment.", var.compartment_ocid))
    error_message = "El OCID del compartment debe comenzar con 'ocid1.compartment.'"
  }
}

variable "region" {
  description = "Región de OCI"
  type        = string
}

# Availability Domain
variable "availablity_domain_name" {
  description = "Availability Domain"
  type        = string
  default     = ""
}

# Network
variable "VCN-CIDR" {
  description = "CIDR para la VCN"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.VCN-CIDR, 0))
    error_message = "El CIDR debe ser válido, ejemplo: 10.0.0.0/16"
  }
}

variable "WebSubnet-CIDR" {
  description = "CIDR para la subnet de servidores web"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.WebSubnet-CIDR, 0))
    error_message = "El CIDR debe ser válido, ejemplo: 10.0.1.0/24"
  }
}

variable "LBSubnet-CIDR" {
  description = "CIDR para la subnet del load balancer"
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.LBSubnet-CIDR, 0))
    error_message = "El CIDR debe ser válido, ejemplo: 10.0.2.0/24"
  }
}

variable "BastionSubnet-CIDR" {
  description = "CIDR para la subnet del bastion"
  type        = string
  default     = "10.0.3.0/24"

  validation {
    condition     = can(cidrhost(var.BastionSubnet-CIDR, 0))
    error_message = "El CIDR debe ser válido, ejemplo: 10.0.3.0/24"
  }
}

# Compute
variable "Shape" {
  description = "Shape para las instancias"
  type        = string
  default     = "VM.Standard.E4.Flex"

  validation {
    condition     = contains(["VM.Standard.E4.Flex", "VM.Standard.E3.Flex"], var.Shape)
    error_message = "Shape debe ser VM.Standard.E4.Flex o VM.Standard.E3.Flex"
  }
}

variable "FlexShapeOCPUS" {
  description = "OCPUs para shapes flexibles"
  type        = number
  default     = 1

  validation {
    condition     = var.FlexShapeOCPUS >= 1 && var.FlexShapeOCPUS <= 64
    error_message = "OCPUs debe estar entre 1 y 64"
  }
}

variable "FlexShapeMemory" {
  description = "Memoria en GB para shapes flexibles"
  type        = number
  default     = 4

  validation {
    condition     = var.FlexShapeMemory >= 1 && var.FlexShapeMemory <= 1024
    error_message = "Memoria debe estar entre 1 y 1024 GB"
  }
}

# Load Balancer
variable "lb_shape" {
  description = "Shape del load balancer"
  type        = string
  default     = "flexible"

  validation {
    condition     = contains(["flexible"], var.lb_shape)
    error_message = "Solo se soporta shape flexible"
  }
}

variable "flex_lb_min_shape" {
  description = "Mínimo bandwidth en Mbps para el LB flexible"
  type        = number
  default     = 10

  validation {
    condition     = var.flex_lb_min_shape >= 10 && var.flex_lb_min_shape <= 8000
    error_message = "El ancho de banda mínimo debe estar entre 10 y 8000 Mbps"
  }
}

variable "flex_lb_max_shape" {
  description = "Máximo bandwidth en Mbps para el LB flexible"
  type        = number
  default     = 100

  validation {
    condition     = var.flex_lb_max_shape >= 10 && var.flex_lb_max_shape <= 8000
    error_message = "El ancho de banda máximo debe estar entre 10 y 8000 Mbps"
  }
}

# Storage
variable "volume_size_in_gbs" {
  description = "Tamaño de los block volumes en GB"
  type        = number
  default     = 100

  validation {
    condition     = var.volume_size_in_gbs >= 50 && var.volume_size_in_gbs <= 32768
    error_message = "El tamaño debe estar entre 50 y 32768 GB"
  }
}

# Health Check
variable "health_check_interval_ms" {
  description = "Intervalo para health checks en ms"
  type        = number
  default     = 10000

  validation {
    condition     = var.health_check_interval_ms >= 1000 && var.health_check_interval_ms <= 60000
    error_message = "El intervalo debe estar entre 1000 y 60000 ms"
  }
}

variable "health_check_timeout_ms" {
  description = "Timeout para health checks en ms"
  type        = number
  default     = 3000

  validation {
    condition     = var.health_check_timeout_ms >= 1000 && var.health_check_timeout_ms <= 20000
    error_message = "El timeout debe estar entre 1000 y 20000 ms"
  }
}

variable "health_check_retries" {
  description = "Número de reintentos para health checks"
  type        = number
  default     = 3

  validation {
    condition     = var.health_check_retries >= 1 && var.health_check_retries <= 10
    error_message = "Los reintentos deben estar entre 1 y 10"
  }
}

# OS Images
variable "instance_os" {
  description = "Sistema operativo para las instancias"
  type        = string
  default     = "Oracle Linux"

  validation {
    condition     = contains(["Oracle Linux"], var.instance_os)
    error_message = "Solo se soporta Oracle Linux"
  }
}

variable "linux_os_version" {
  description = "Versión del sistema operativo"
  type        = string
  default     = "8"

  validation {
    condition     = contains(["7", "8"], var.linux_os_version)
    error_message = "Versión debe ser 7 u 8"
  }
}

# FSS
variable "MountTargetIPAddress" {
  description = "IP para el Mount Target de FSS"
  default     = "10.0.1.25"
}

# Compartment
variable "compartment_name" {
  description = "Nombre del compartment"
  default     = "FoggyKitchenCompartment"
}

locals {
  common_tags = {
    environment = "production"
    project     = "foggykitchen"
    terraform   = "true"
  }
}

locals {
  compute_flexible_shapes = [
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.Optimized3.Flex"
  ]
}

locals {
  is_flexible_shape    = contains(local.compute_flexible_shapes, var.Shape)
  is_flexible_lb_shape = var.lb_shape == "flexible" ? true : false
}
