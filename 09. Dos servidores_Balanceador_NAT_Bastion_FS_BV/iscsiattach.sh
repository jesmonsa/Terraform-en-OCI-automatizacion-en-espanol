#!/bin/bash
# iscsiattach.sh - Scan and automatically attach new iSCSI targets

# Habilitar el modo de depuración
set -x

# Configurar manejo de errores
set -e

BASEADDR="169.254.2.2"
addrCount=0

# Asegurarse de que iscsiadm está instalado
if ! command -v iscsiadm &> /dev/null; then
    echo "Installing iscsi-initiator-utils..."
    sudo yum install -y iscsi-initiator-utils
fi

# Asegurarse de que el servicio iscsid está activo
sudo systemctl start iscsid
sudo systemctl enable iscsid

# Función de limpieza
cleanup() {
    find . -maxdepth 1 -type p -exec rm -f {} \; 2>/dev/null || true
}

# Registrar la función de limpieza para ejecutarse al salir
trap cleanup EXIT

while [ ${addrCount} -le 1 ]; do
    CURRADDR=$(echo ${BASEADDR} | awk -F\. '{last=$4+'${addrCount}';print $1"."$2"."$3"."last}')
    
    echo "Attempting connection to ${CURRADDR}"
    
    # Crear pipe con nombre único
    DISCPIPE="/tmp/discpipe_$$"
    SESSPIPE="/tmp/sesspipe_$$"
    
    mkfifo "${DISCPIPE}" || { echo "Failed to create FIFO ${DISCPIPE}"; exit 1; }
    
    # Descubrir targets
    if ! timeout 30 iscsiadm -m discovery -t st -p ${CURRADDR}:3260 | grep -v uefi | awk '{print $2}' > "${DISCPIPE}"; then
        echo "No targets found at ${CURRADDR}"
        rm -f "${DISCPIPE}"
        (( addrCount = addrCount + 1 ))
        continue
    fi
    
    # Procesar cada target encontrado
    while read target; do
        mkfifo "${SESSPIPE}" || { echo "Failed to create FIFO ${SESSPIPE}"; continue; }
        
        if ! timeout 30 iscsiadm -m session -P 0 | grep -v uefi | awk '{print $4}' > "${SESSPIPE}"; then
            echo "No existing sessions found"
            rm -f "${SESSPIPE}"
            continue
        fi
        
        found="false"
        while read session; do
            if [ "${target}" = "${session}" ]; then
                found="true"
                break
            fi
        done < "${SESSPIPE}"
        
        rm -f "${SESSPIPE}"
        
        if [ "${found}" = "false" ]; then
            echo "Configuring new target: ${target}"
            iscsiadm -m node -o new -T ${target} -p ${CURRADDR}:3260
            iscsiadm -m node -o update -T ${target} -n node.startup -v automatic
            iscsiadm -m node -T ${target} -p ${CURRADDR}:3260 -l
            sleep 5
            
            # Verificar si el login fue exitoso
            if ! iscsiadm -m session | grep -q "${target}"; then
                echo "Failed to login to target ${target}"
                continue
            fi
        fi
    done < "${DISCPIPE}"
    
    rm -f "${DISCPIPE}"
    (( addrCount = addrCount + 1 ))
done

echo "Scan Complete"
exit 0
