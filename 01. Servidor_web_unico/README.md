# 🌐 Arquitectura - Servidor Web Único en OCI

*Patrón básico de servidor web en Oracle Cloud Infrastructure*

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/jesmonsa/Terraform-en-OCI-automatizacion-en-espanol/archive/refs/heads/master.zip)

## 📋 Descripción de la Arquitectura

Esta arquitectura implementa un servidor web único en OCI con los siguientes componentes:

- ✅ **1 Compartimento** - Para organizar los recursos
- ✅ **1 VCN** - Red virtual con CIDR `10.0.0.0/16`
- ✅ **1 Subred Pública** - Con CIDR `10.0.1.0/24`
- ✅ **1 VM WebServer** - Con Oracle Linux 8
- ✅ **Internet Gateway** - Para conectividad a Internet
- ✅ **Security List** - Reglas para puertos 22 (SSH), 80 (HTTP) y 443 (HTTPS)

### 🎯 **Casos de Uso Ideales:**
- 🧪 **Entornos de desarrollo** - Configuración rápida
- 📚 **Aprendizaje** - Introducción a OCI
- 🚀 **Pruebas de concepto** - Validación de ideas

## 🏗️ Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    Internet                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│                VCN (10.0.0.0/16)                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              Internet Gateway                           │ │
│  └─────────────────────┬───────────────────────────────────┘ │
│                        │                                     │
│  ┌─────────────────────▼───────────────────────────────────┐ │
│  │          Subred Pública (10.0.1.0/24)                   │ │
│  │                                                         │ │
│  │     ┌─────────────────────────────────────────────┐     │ │
│  │     │           WebServer VM                      │     │ │
│  │     │        - Oracle Linux 8                     │     │ │
│  │     │        - Apache HTTPD                       │     │ │
│  │     │        - Puertos: 22, 80, 443               │     │ │
│  │     └─────────────────────────────────────────────┘     │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## ⚡ Despliegue Rápido

### Opción 1: Usando Oracle Resource Manager

1. **Click en "Deploy to Oracle Cloud"** arriba
2. **Inicia sesión** en tu tenancy OCI
3. **Revisa y acepta** términos y condiciones  
4. **Selecciona la región** de despliegue
5. **Click en "Plan"** para revisar los recursos
6. **Click en "Apply"** para crear la infraestructura

### Opción 2: Terraform Local

```bash
# 1. Clonar y navegar
git clone https://github.com/jesmonsa/Terraform-en-OCI-automatizacion-en-espanol.git
cd Terraform-en-OCI-automatizacion-en-espanol/01.\ Servidor_web_unico/

# 2. Configurar variables
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars con tus credenciales

# 3. Inicializar y desplegar
terraform init
terraform plan
terraform apply
```

## 🔐 Configuración de Variables

### Archivo terraform.tfvars
```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaXXXXXX"
user_ocid        = "ocid1.user.oc1..aaaaaaaXXXXXX"
fingerprint      = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
private_key_path = "/ruta/a/tu/llave/privada.pem"
region           = "us-ashburn-1"  # Cambia según tu región
```

## 🚀 Comandos Básicos

```bash
# Inicializar
terraform init

# Ver plan
terraform plan

# Aplicar cambios
terraform apply

# Destruir recursos
terraform destroy
```

## ✅ Validación del Despliegue

### Verificar en OCI Console:
- ✅ Compartimento creado
- ✅ VCN desplegada
- ✅ VM en estado "Running"
- ✅ IP pública asignada

### Probar conectividad:
```bash
# SSH a la VM
ssh -i /ruta/a/tu/llave/privada opc@IP_PUBLICA

# Verificar servicio web
curl http://IP_PUBLICA
```

## 📊 Recursos Creados

| Recurso | Tipo | Descripción |
|---------|------|-------------|
| Compartimento | `oci_identity_compartment` | Contenedor lógico |
| VCN | `oci_core_vcn` | Red virtual (10.0.0.0/16) |
| Internet Gateway | `oci_core_internet_gateway` | Conectividad Internet |
| Route Table | `oci_core_route_table` | Tabla de enrutamiento |
| Security List | `oci_core_security_list` | Reglas de firewall |
| Subred | `oci_core_subnet` | Subred (10.0.1.0/24) |
| Compute Instance | `oci_core_instance` | VM con Oracle Linux 8 |
| Configuración Web | `null_resource` | Instalación de Apache HTTPD |

## 💰 Estimación de Costos

### Con OCI Free Tier:
- ✅ **$0/mes** - Eligible para Always Free
- ✅ **2 VMs ARM Ampere** incluidas
- ✅ **Networking básico** gratuito

### Con recursos pagos:
- 💵 **~$15-30/mes** - VM Standard (1-2 OCPUs)
- 💵 **~$1-5/mes** - Networking y almacenamiento

## 🛡️ Consideraciones de Seguridad

### ⚠️ **Limitaciones:**
- 🔓 **VM en subred pública** - Expuesta a Internet
- 🔓 **Sin NAT Gateway** - Conectividad directa

### 🛡️ **Mejoras recomendadas:**
- 🔐 **Network Security Groups** - Para seguridad granular
- 🌐 **WAF** - Protección adicional para tráfico web

---

<div align="center">
**Creado por [Tu Nombre](https://github.com/tuusuario) • Basado en [FoggyKitchen](https://github.com/mlinxfeld/foggykitchen_tf_oci_course)**
</div>