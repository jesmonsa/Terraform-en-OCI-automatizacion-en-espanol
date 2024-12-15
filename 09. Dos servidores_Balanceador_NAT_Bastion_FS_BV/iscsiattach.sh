#!/bin/bash
# iscsiattach.sh - Escanea y conecta automáticamente nuevos objetivos iSCSI
#
# Autor: Steven B. Nelson, adaptado por Jesus Montoya
# Fecha: 20 April 2017, revisado el 14 December 2024
# Copyright Oracle, Inc. Todos los derechos reservados.

BASEADDR="169.254.2.2"  # Dirección base para discovery. Ajustar si es necesario.
TIMEOUT=30              # Tiempo máximo de espera en segundos.
MAX_ADDR=32             # Máximo de direcciones a probar.
addrCount=0             # Contador inicial.

# Verificar que las herramientas necesarias están disponibles
command -v iscsiadm >/dev/null 2>&1 || { echo "Error: 'iscsiadm' no está instalado."; exit 1; }
command -v awk >/dev/null 2>&1 || { echo "Error: 'awk' no está instalado."; exit 1; }
command -v timeout >/dev/null 2>&1 || { echo "Error: 'timeout' no está instalado."; exit 1; }

# Limpiar posibles pipes previos
find . -maxdepth 1 -type p -exec rm {} \; 2>/dev/null

# Iterar sobre direcciones IP
while [ ${addrCount} -lt ${MAX_ADDR} ]; do
    # Generar la dirección IP actual
    CURRADDR=$(echo "${BASEADDR}" | awk -F\. '{last=$4+'${addrCount}';print $1"."$2"."$3"."last}')
    echo "Intentando conexión a ${CURRADDR}..."

    # Crear pipe para manejar discovery
    mkfifo discpipe

    # Intentar discovery con timeout
    timeout ${TIMEOUT} iscsiadm -m discovery -t st -p ${CURRADDR}:3260 | grep -v uefi | awk '{print $2}' > discpipe 2>/dev/null &
    result=$?

    if [ ${result} -ne 0 ]; then
        echo "Error: No se pudo conectar a ${CURRADDR}. Saltando."
        (( addrCount++ ))
        find . -maxdepth 1 -type p -exec rm {} \;
        continue
    fi

    # Iterar sobre targets descubiertos
    while read -r target; do
        echo "Verificando target: ${target}"

        # Crear pipe para sesiones
        mkfifo sesspipe
        timeout ${TIMEOUT} iscsiadm -m session -P 0 | grep -v uefi | awk '{print $4}' > sesspipe 2>/dev/null &
        
        # Buscar si ya está configurado
        found="false"
        while read -r session; do
            if [ "${target}" = "${session}" ]; then
                found="true"
                break
            fi
        done < sesspipe

        # Configurar target si no está presente
        if [ "${found}" = "false" ]; then
            echo "Configurando target: ${target} en ${CURRADDR}"
            iscsiadm -m node -o new -T ${target} -p ${CURRADDR}:3260
            iscsiadm -m node -o update -T ${target} -n node.startup -v automatic
            iscsiadm -m node -T ${target} -p ${CURRADDR}:3260 -l
            sleep 10
        else
            echo "Target ${target} ya está configurado. Saltando."
        fi
    done < discpipe

    # Incrementar contador y limpiar pipes
    (( addrCount++ ))
    find . -maxdepth 1 -type p -exec rm {} \;
done

echo "Proceso de escaneo y configuración completado."