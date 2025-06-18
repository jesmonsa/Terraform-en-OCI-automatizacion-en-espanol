# 🚀 Terraform en OCI - Servidor Web Único

![Arquitectura del Servidor Web Único](Servidor%20unico.png)

## 📋 Descripción

Este proyecto implementa un servidor web único en Oracle Cloud Infrastructure (OCI) utilizando Terraform. La infraestructura desplegada crea un entorno completo que incluye redes, seguridad y computación, todo configurado automáticamente.

## 🏗️ Arquitectura

El despliegue crea los siguientes componentes en OCI:

| Componente | Descripción |
|-----------|-------------|
| **Compartimento** | Contenedor lógico para organizar y aislar recursos |
| **VCN** | Red virtual con CIDR `10.0.0.0/16` |
| **Subred Pública** | Subred con CIDR `10.0.1.0/24` accesible desde Internet |
| **Internet Gateway** | Permite la conectividad saliente a Internet |
| **Tabla de Rutas** | Configura el tráfico de red hacia Internet |
| **Lista de Seguridad** | Permite tráfico en puertos 22 (SSH), 80 (HTTP) y 443 (HTTPS) |
| **Instancia Compute** | VM.Standard.E5.Flex con Oracle Linux 8 |
| **Servidor Web** | Apache HTTPD instalado y configurado automáticamente |

## 🔧 Requisitos Previos

- Cuenta en Oracle Cloud Infrastructure
- Permisos adecuados para crear recursos
- Conocimientos básicos de Terraform y OCI

## 🚀 Instrucciones de Despliegue

### Opción 1: Despliegue Local

1. Clone este repositorio
2. Configure sus credenciales de OCI
3. Ejecute:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Opción 2: Oracle Resource Manager

1. Haga clic en el botón para desplegar:

   [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/nuevo-repo/foggykitchen_tf_oci_course/releases/latest/download/LESSON1_single_webserver.zip)

2. Siga el asistente de configuración:
   - Inicie sesión con sus credenciales de OCI
   - Acepte los términos y condiciones
   - Seleccione la región de despliegue
   - Configure las variables según sea necesario

3. Ejecute el plan y aplique los cambios:
   - Haga clic en **Terraform Actions** → **Plan**
   - Revise los cambios propuestos
   - Haga clic en **Terraform Actions** → **Apply**

## 📊 Resultados

Al finalizar el despliegue, obtendrá:

- Una dirección IP pública para acceder al servidor web
- Una clave SSH privada generada para conectarse a la instancia
- Un servidor web básico con una página de bienvenida

## 📚 Recursos Adicionales

- [Documentación de Terraform](https://www.terraform.io/docs)
- [Documentación de Oracle Cloud Infrastructure](https://docs.oracle.com/iaas/Content/home.htm)
- [Guía de Terraform para OCI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraform.htm)

## 🔄 Variables Personalizables

Este proyecto permite personalizar varios aspectos mediante variables en `variables.tf`:

- Forma de la instancia y recursos de computación
- CIDRs de red
- Versión del sistema operativo
- Puertos de servicio permitidos