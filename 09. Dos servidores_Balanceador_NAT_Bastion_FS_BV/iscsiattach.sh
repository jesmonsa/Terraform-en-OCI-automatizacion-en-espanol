#!/bin/bash
# iscsiattach.sh - Scan and automatically attach new iSCSI targets
#
# Author: Steven B. Nelson, Sr. Solutions Architect
#       Oracle Cloud Infrastructure
#
# 20 April 2017
# Copyright Oracle, Inc.  All rights reserved.

BASEADDR="169.254.2.2"  # Asegúrate de que esta dirección IP sea la correcta.
TIMEOUT=30              # Timeout explícito para evitar bloqueos en iscsiadm.

# Set a base address incrementor so we can loop through all the addresses.
addrCount=0

# Iterar sobre un rango de direcciones IP
while [ ${addrCount} -le 1 ]
do
    # Generar la dirección actual
    CURRADDR=`echo ${BASEADDR} | awk -F\. '{last=$4+'${addrCount}';print $1"."$2"."$3"."last}'`

    clear
    echo "Intentando conexión a ${CURRADDR}"

    # Crear el FIFO para discovery
    mkfifo discpipe

    # Realizar el discovery con timeout
    timeout ${TIMEOUT} iscsiadm -m discovery -t st -p ${CURRADDR}:3260 | grep -v uefi | awk '{print $2}' > discpipe 2>/dev/null &
    result=$?

    # Manejo de error si no hay conexión
    if [ ${result} -ne 0 ]; then
        echo "Error: No se pudo conectar a ${CURRADDR} en el puerto 3260. Saltando a la siguiente dirección."
        (( addrCount = addrCount + 1 ))
        find . -maxdepth 1 -type p -exec rm {} \;  # Limpiar pipes
        continue
    fi

    # Iterar sobre los targets descubiertos
    while read target
    do
        mkfifo sesspipe
        timeout ${TIMEOUT} iscsiadm -m session -P 0 | grep -v uefi | awk '{print $4}' > sesspipe 2>/dev/null &
        
        # Verificar si el target ya está configurado
        found="false"
        while read session
        do
            if [ "${target}" = "${session}" ]; then
                found="true"
                break
            fi
        done < sesspipe

        # Configurar el target si no está presente
        if [ "${found}" = "false" ]; then
            echo "Configurando target: ${target}"
            iscsiadm -m node -o new -T ${target} -p ${CURRADDR}:3260
            iscsiadm -m node -o update -T ${target} -n node.startup -v automatic
            iscsiadm -m node -T ${target} -p ${CURRADDR}:3260 -l
            sleep 10
        else
            echo "Target ${target} ya configurado. Saltando."
        fi
    done < discpipe

    # Incrementar contador y limpiar pipes
    (( addrCount = addrCount + 1 ))
    find . -maxdepth 1 -type p -exec rm {} \;
done

echo "Escaneo completo."