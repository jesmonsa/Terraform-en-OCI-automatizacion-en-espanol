# Infraestructura OCI con Balanceador, NAT, Bastion y Almacenamiento

## Descripción General

Este proyecto implementa una infraestructura completa en Oracle Cloud Infrastructure (OCI) que incluye:

- Dos servidores web en una subred privada
- Un balanceador de carga público
- Un servidor bastion para acceso SSH
- Sistema de archivos compartido (FSS)
- Volúmenes de bloque para almacenamiento adicional
- Gateway NAT para acceso a Internet desde las subredes privadas

## Arquitectura

La infraestructura se compone de:

1. **Networking**:
   - VCN con CIDR 10.0.0.0/16
   - Subred privada para servidores web (10.0.1.0/24)
   - Subred pública para balanceador (10.0.2.0/24)
   - Subred pública para bastion (10.0.3.0/24)
   - NAT Gateway y Internet Gateway

2. **Compute**:
   - 2 servidores web Oracle Linux 8
   - 1 servidor bastion
   - Todos usando shape flexible VM.Standard.E4.Flex

3. **Almacenamiento**:
   - File Storage Service (FSS) compartido
   - Volúmenes de bloque de 100GB para cada servidor web

4. **Balanceo de Carga**:
   - Balanceador público flexible
   - Health checks configurados
   - Round-robin entre servidores web

## Requisitos Previos

1. Cuenta en OCI con privilegios adecuados
2. Terraform v1.0.0 o superior
3. OCI CLI configurado (opcional)

## Variables de Entorno Necesarias

```bash
export TF_VAR_tenancy_ocid="your_tenancy_ocid"
export TF_VAR_user_ocid="your_user_ocid"
export TF_VAR_fingerprint="your_api_key_fingerprint"
export TF_VAR_private_key_path="path_to_your_private_key"
export TF_VAR_region="your_region"
export TF_VAR_compartment_ocid="your_compartment_ocid"
```

## Despliegue

1. Clonar el repositorio
2. Configurar variables de entorno
3. Inicializar Terraform:
   ```bash
   terraform init
   ```
4. Planear el despliegue:
   ```bash
   terraform plan
   ```
5. Aplicar la configuración:
   ```bash
   terraform apply
   ```

## Acceso a los Servidores

1. **Bastion**:
   - SSH directo usando la clave privada generada
   - IP pública disponible en los outputs

2. **Servidores Web**:
   - SSH a través del bastion
   - Acceso web a través del balanceador de carga

## Mantenimiento

1. **Backups**:
   - Los volúmenes de bloque pueden tener política de backup
   - FSS soporta snapshots

2. **Monitoreo**:
   - Health checks del balanceador
   - Métricas de compute y storage disponibles

3. **Seguridad**:
   - Security lists configuradas
   - Acceso SSH restringido vía bastion
   - SELinux habilitado y configurado

## Destrucción de Recursos

Para eliminar toda la infraestructura:
```bash
terraform destroy
```

## Notas Importantes

1. Los servidores web están en una subred privada
2. El balanceador es el único punto de acceso público a los servicios web
3. Todo el acceso SSH debe realizarse a través del bastion
4. Los volúmenes de bloque y FSS persisten aunque se destruyan las instancias

## Soporte

Para problemas o mejoras, por favor abrir un issue en el repositorio.
